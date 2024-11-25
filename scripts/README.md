# scripts

Contains shell scripts for provisioning and sub-routines in the Terraform infrastructure deployment process.

## Dependencies

| Name       | Version | Description                               |
|------------|---------|-------------------------------------------|
| terraform  |         | Infrastructure as Code tool               |
| AWS CLI    |         | Command-line interface for AWS            |
| jq         |         | Lightweight JSON processor                |
| tflint     |         | Terraform linter for identifying errors   |



## sub_routines.sh

This placeholder contains bash method which would referred either by the sub_routines or provisioner bash scripts.

### Functions:

- **command_exists** : This method checks whether given binary exists in the local system.
- **Cleanup_failed_changeset** : Cleans up failed CloudFormation change sets.
- **fetch_terraform_backend_info** : Fetches Terraform backend information.
- **terraform_bootstrap** : Converges Terraform bootstrap stack.
- **terraform_init_with_backend** : Initializes Terraform with backend configuration.
- **terraform_lint** : Runs Terraform linter ('tflint') to check issues.
- **terraform_fmt** : Formats Terraform code for consistent style.
- **terraform_validate** : Validates Terraform code for errors.
- **terraform_plan** : Generates Terraform execution plan.
- **terraform_apply** : Applies Terraform execution plan.
- **terraform_destroy** : Destroys Terraform-managed infrastructure.
- **terraform_switch_deploy_role** : Switches AWS IAM role for deployment.	
- **read_current_env_variables** : Reads current AWS environment variables.
- **aws-set-session-variables** : Sets AWS session variables based on assumed role.
- **aws-stop-session** : Stops the current AWS session.
- **terraform_sync_secrets** : Syncs secrets from S3 to a local directory.

## provisioner.sh

Bash script automating Terraform tasks (init, validate, plan, apply, destroy) for specified environment and applications.

### Functions:

- **main**: Orchestrates Terraform actions based on input parameters.
- **terraform-bootstrap**: Bootstraps the Terraform setup for the specified environment.
- **terraform-init**: Initializes Terraform with a backend for the specified environment and/or application.
- **terraform-verify**: Performs validation stages for Terraform configuration and code.
- **terraform-plan**: Generates and displays an execution plan for Terraform changes without applying them.
- **terraform-apply**: Applies Terraform changes to the infrastructure.
- **terraform-destroy**: Destroys Terraform-managed infrastructure.
- **(*)** : Default case for invalid input.

## k8s_pod_cleaner.sh

- To list all pods across all namespaces in a Kubernetes cluster.
- Retrieves all namespaces using `kubectl get namespaces`.
- Iterates over each namespace and lists the pods using `kubectl get pods -n $EACH_NAMESPACE`.

## Instructions : 

- **Execute script** : Run the script with the desired action, environment, and application parameters.
- To execute a command :  `./<script_name>.sh <action> <environment> <application>`  (bash) 

### Note :

- Ensure that AWS CLI, jq, and tflint are installed and configured with the necessary credentials before using the repository.



