#!/usr/bin/env bash
source scripts/sub_routines.sh
main(){
  action=$1
  env=$2
  app=${3}
  if [ "${app}" == "ALL" ]; then
		source environments/${env}/app_flow.sh
  	read -p "Provide the Application target : " app_target
  	if [ -z "${app_target}" ]; then
  		echo "${app_taget} application target doesnt exists"
  		exit 1
		else
  	 APPS=${app_taget}
  	fi
	else
  	APPS=${app}
  fi
  case ${action} in
    "terraform-bootstrap")
    	account_id=$(aws sts get-caller-identity --query "Account" --output text)
      echo "Bootstrapping for ${account_id} environment"
      stack_name="terraform-state-${account_id}"
      cleanup_failed_changeset ${stack_name}
      terraform_bootstrap ${stack_name}
    ;;
  	"terraform-init")
			aws_switch_deploy_role
  		echo "Initializing Terraform for ${env}"
			terraform_sync_secrets
			for EACH_APP in ${APPS}; do
				EACH_APP=$(basename $EACH_APP)
				#EACH_APP=${EACH_APP#*_}
				echo "Working for $EACH_APP"
				cd environments/"${env}/${EACH_APP}"
				terraform_fmt
				terraform_init_with_backend "${env}"
  			cd -
  		done
		;;
		"terraform-verify")
			aws_switch_deploy_role
			terraform_sync_secrets
			for EACH_APP in ${APPS}; do
				EACH_APP=$(basename $EACH_APP)
				echo "Initializing Terraform validation suite for ${env}/${EACH_APP}"
				cd environments/"${env}/${EACH_APP}"
				terraform_lint ${env}
				terraform_validate ${env}
  			cd -
  		done
		;;
		"terraform-plan")
			aws_switch_deploy_role
			terraform_sync_secrets
			for EACH_APP in ${APPS}; do
				EACH_APP=$(basename $EACH_APP)
				echo "Terraform plan  for ${env}/${EACH_APP}"
				cd environments/"${env}/${EACH_APP}"
				terraform_plan "${env}"
				cd -
			done
		;;
		"terraform-apply")
			aws_switch_deploy_role
			terraform_sync_secrets
			for EACH_APP in ${APPS}; do
				EACH_APP=$(basename $EACH_APP)
				echo "Performing terraform apply for ${env}/${EACH_APP}"
				cd environments/"${env}/${EACH_APP}"
					terraform_apply "${env}"
				cd -
			done
		;;
		"terraform-destroy")
			aws_switch_deploy_role
			terraform_sync_secrets
			for EACH_APP in ${APPS}; do
				EACH_APP=$(basename $EACH_APP)
				echo "Performing terraform destroy for ${env}/${EACH_APP}"
				cd environments/"${env}/${EACH_APP}"
				terraform_destroy "${env}"
				cd -
			done
		;;
    "*")
      echo "Invalid Input, please check your command.";;
  esac
}
main "$@"