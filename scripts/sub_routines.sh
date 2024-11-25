#!/usr/bin/env bash
SECRETS_BASE_DIRECTORY="secrets"
SECRETS_TFVAR_DIRECTORY="${SECRETS_BASE_DIRECTORY}/secret-tfvars"
command_exists() {
  # Check any essential tool exists
  binary_name=${1}
  command -v "${binary_name}" > /dev/null 2 >&1
  if [[ $? -ne 0 ]]; then
    echo "I require $1 but it is not installed, Aborting now"
    exit 1
  fi
}
cleanup_failed_changeset() {
	command_exists aws
	stack_name=${1}
	CHANGE_SETS=$(aws cloudformation list-change-sets --stack-name ${stack_name} --query 'Summaries[?Status==`FAILED`].ChangeSetId' --output text)
	CHANGET_SET_COUNT=$(echo ${CHANGE_SETS} | wc -w)
	echo "Cleaning ${CHANGET_SET_COUNT:-0} failed changesets of the stack ${stack_name}"
	for EACH_CHANGE_SET in ${CHANGE_SETS}; do
		aws cloudformation delete-change-set --change-set-name ${EACH_CHANGE_SET}
	done
}

fetch_terraform_backend_info(){
	if [[ -z "${AWS_ACCOUNT_ID}" ]]; then
		export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
	fi
	if [[ -z "${AWS_REGION}" ]]; then
		export AWS_REGION="$(aws configure get region)"
	fi
	if [[ -z "${TF_STATE_BUCKET}" ]]; then
		export TF_STATE_BUCKET=$(aws ssm get-parameter --name "/terraform/${AWS_REGION}/state_bucket" --query "Parameter.Value" --output text)
	fi
	if [[ -z "${TF_DYNAMODB_TABLE}" ]]; then
		export TF_DYNAMODB_TABLE=$(aws ssm get-parameter --name "/terraform/${AWS_REGION}/dynamodb_table" --query "Parameter.Value" --output text)
	fi
}

terraform_bootstrap(){
	stack_name=${1}
	fetch_terraform_backend_info
	echo "Converging ${stack_name} for ${AWS_REGION}"
	aws cloudformation deploy --region ${AWS_REGION}\
		--stack-name ${stack_name} \
		--template-file templates/terraform_bootstrap.cfn.yaml \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--output text \
		--no-fail-on-empty-changeset
	aws cloudformation update-termination-protection \
	  --stack-name "${stack_name}" \
	  --enable-termination-protection
}

terraform_init_with_backend(){
	command_exists terraform
	env=${1}
	fetch_terraform_backend_info
	terraform init -migrate-state --backend=true \
		-backend-config="region=${AWS_REGION}" \
		-backend-config="bucket=${TF_STATE_BUCKET}" \
		-backend-config="dynamodb_table=${TF_DYNAMODB_TABLE}"
	if [[ "$(terraform workspace list | grep -w "${env}")" == 0 ]]; then
		terraform workspace new "${env}"
	else
		terraform workspace select -or-create "${env}"
		echo "Switched to workspace ${env}"
	fi
}
terraform_lint() {
	command_exists tflint
	env=${1}
	tflint --minimum-failure-severity="warning"
	if [[ $? -ne 0 ]]; then
		echo "Terraform Lint has failed, hence breaking the build now"
	fi
}
terraform_fmt() {
	command_exists terraform
	terraform fmt -check -recursive -write=false -list=false
	if [[ $? -eq 3 ]]; then
		echo "Terraform formatting errors validated"
	else
		echo "Terraform formatting errors found"
		exit 1
	fi
}
terraform_validate(){
	command_exists terraform
	command_exists jq
	ERROR_COUNT=$(terraform validate -json | jq .error_count)
	if [[ "${ERROR_COUNT}" -ne "0" ]]; then
		echo "Errors found while validating terraform"
		terraform validate
	fi
}
terraform_plan(){
	command_exists terraform
	env=${1}
	TF_VAR_LIST=""
	for EACH in $(find "../../../env-tfvars/${env}" -type f); do
		TF_VAR_LIST+=" -var-file=${EACH}";
	done
	if [[ $(readlink -f "../../../${SECRETS_TFVAR_DIRECTORY}/${env}.tfvars") ]]; then
		terraform plan -compact-warnings \
			-detailed-exitcode  \
			-out=terraformplan.out \
			-var-file="../../../${SECRETS_TFVAR_DIRECTORY}/${env}.tfvars" \
			${TF_VAR_LIST}
	else
		terraform plan -compact-warnings \
			-detailed-exitcode  \
			-out=terraformplan.out \
			${TF_VAR_LIST}
	fi
	if [[ $? -ne 0 ]]; then
		echo "Terraform plan executed successfully"
	fi
}
terraform_apply(){
	command_exists terraform
	env=${1}
	if [ ! -f "terraformplan.out" ]; then
		terraform_plan "${env}"
	fi
	terraform apply terraformplan.out
	if [[ $? -ne 0 ]]; then
		echo "Terraform plan applied successfully"
		rm -rf terraformplan.out
	fi
}
terraform_destroy(){
	command_exists terraform
	env=${1}
	TF_VAR_LIST=""
	for EACH in $(find "../../../env-tfvars/${env}" -type f); do
		TF_VAR_LIST+=" -var-file=${EACH}";
	done
	if [ ! -f "terraformplan.out" ]; then
		terraform_plan "${env}"
	fi
	if [[ $(readlink -f "../../../${SECRETS_TFVAR_DIRECTORY}/${env}.tfvars") ]]; then
		terraform destroy \
			-var-file="../../../${SECRETS_TFVAR_DIRECTORY}/${env}.tfvars" \
			${TF_VAR_LIST}
	else
		terraform destroy \
			${TF_VAR_LIST}
	fi
}
aws_switch_deploy_role() {
	fetch_terraform_backend_info
	command_exists jq
	aws_role="${1:-"AutomationDeployRole"}_${AWS_ACCOUNT_ID}"
	role_arn="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${aws_role}"
	aws sts assume-role --role-arn "${role_arn}" --role-session-name "${aws_role}" --output json > .credentials.tmp
	if [[ $? == 0 ]]; then
		aws-set-session-variables
		rm -f .credentials.tmp
		echo -e "\nSuccessfully switched to ${aws_role}"
	else
	 	echo -e "\nFailed to switch role, check if you have access to ${aws_role} role on AWS console or contact admin\n"
	 	exit
	fi
}
read_current_env_variables(){
	if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
		USER_AWS_ACCOUNT_ID=$AWS_ACCESS_KEY_ID
	fi
	if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
		USER_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
	fi
	if [[ -z "${AWS_SESSION_TOKEN}" ]]; then
		USER_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
	fi
}
aws-set-session-variables() {
	if [[ -e ".credentials.tmp" ]]; then
		export AWS_ACCESS_KEY_ID=$(cat .credentials.tmp | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(cat .credentials.tmp | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(cat .credentials.tmp | jq -r .Credentials.SessionToken)
	else
		echo "credentials not set for deployment role"
	fi
}
aws-stop-session() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
}
terraform_sync_secrets () {
	echo "Synchronizing Secrets from ${TF_STATE_BUCKET} to ${SECRETS_BASE_DIRECTORY}"
	aws s3 sync s3://${TF_STATE_BUCKET}/${SECRETS_BASE_DIRECTORY} ${SECRETS_BASE_DIRECTORY}
}