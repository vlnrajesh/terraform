# rds aws module

This directory contains Terraform configuration files for creating an Amazon RDS (Relational Database Service) instance. 

## rds

### Directory Structure
- `main.tf`: Central Terraform configuration file for managing RDS instances and related resources.
- Subdirectories:
  - `modules`: Contains submodules for managing different aspects of RDS, such as subnet groups, parameter groups, option groups, and secret rotation.
- `modules` Subdirectories:
  - `subnet_group`: Manages RDS subnet groups.
  - `parameter_group`: Manages RDS parameter groups.
  - `option_group`: Manages RDS option groups.
  - `rds-secret-rotation`: Manages RDS secret rotation configuration.
- `variables.tf`, `outputs.tf`, and other supporting files may be present but are not shown in the provided file paths.

### Terraform Configuration
- Defines local variables for determining the names of subnet groups, parameter groups, and option groups based on whether they are created or specified externally.
- Utilizes modules to create and manage various RDS-related resources:
  - `db_security_group`: Creates an RDS security group.
  - `db_subnet_group`: Creates an RDS subnet group if `create_subnet_group` is set to true.
  - `db_parameter_group`: Creates an RDS parameter group if `create_parameter_group` is set to true.
  - `option_group`: Creates an RDS option group if `create_option_group` is set to true.
  - `aws_db_instance`: Defines the RDS instance with specified configurations, including subnet group, parameter group, option group, security groups, and other attributes.
  - `aws_secretsmanager_secret` and `aws_secretsmanager_secret_version`: Creates and manages secrets for RDS credentials.
  - `rds-secret-rotation`: Configures RDS secret rotation using a custom Lambda function.

### Purpose
- The `main.tf` file orchestrates the creation and management of RDS instances and associated resources within AWS.
- Modularization allows for easier management and customization of RDS-related components.
- Secret rotation ensures the security of RDS credentials by regularly rotating them.

## option_group

- This file defines a Terraform module for creating an RDS option group in AWS.
- It uses locals to define the name of the option group based on the provided `db_identifier_name` variable.
- The `aws_db_option_group` resource is used to create the option group.
  - The `count` parameter determines whether the option group should be created based on the value of the `create` variable.
  - Key parameters include:
    - **Name**: Name of the option group, derived from the local `name`.
    - **Option Group Description**: Description for the option group.
    - **Engine Name**: Name of the database engine.
    - **Major Engine Version**: Major version of the database engine.
    - **Option Settings**: Dynamic block for configuring various options for the option group.
    - **Tags**: Tags to apply to the option group for identification purposes.
  - The `lifecycle` block ensures that the option group is created before any existing option group is destroyed, allowing for seamless updates.

## parameter_group

- This file defines a Terraform module for creating an RDS parameter group in AWS.
- It uses locals to define the name of the parameter group based on the provided `db_identifier_name` variable.
- The `aws_db_parameter_group` resource is used to create the parameter group.
  - The `count` parameter determines whether the parameter group should be created based on the value of the `create` variable.
  - Key parameters include:
    - **Name**: Name of the parameter group, derived from the local `name`.
    - **Description**: Description for the parameter group.
    - **Family**: Family of the database engine parameter group.
    - **Parameters**: Dynamic block for defining the parameters and their values for the parameter group.
    - **Tags**: Tags to apply to the parameter group for identification purposes.
  - The `lifecycle` block ensures that the parameter group is created before any existing parameter group is destroyed, allowing for seamless updates.

## rds-secret-rotation group

### Directory Structure

- `functions`: Contains Python files and the Lambda function code for rotating RDS secrets.
  - `postgres_single_user_rotator`: Contains Python modules for rotating secrets for PostgreSQL RDS instances.
    - `psycopg2`: Contains Python library files required by the PostgreSQL secret rotation function.
- `main.tf`: Defines Terraform resources for setting up RDS secret rotation.
  - Uses data sources to fetch the current AWS caller identity and region.
  - Defines local variables for paths and resource names.
  - Utilizes the `archive_file` data source to create a zip package of the Lambda function code, excluding unnecessary files and directories.
  - Creates an IAM role for the Lambda function with a trust policy allowing Lambda service to assume the role.
  - Defines an IAM policy for the Lambda function with permissions to access CloudWatch Logs and Secrets Manager.
  - Attaches IAM policies to the Lambda function role.
  - Defines a Lambda function resource with the specified runtime, handler, memory size, timeout, and VPC configuration.
  - Configures environment variables for the Lambda function, including the Secrets Manager endpoint.
  - Creates a Secrets Manager secret rotation resource linked to the Lambda function for rotating RDS passwords.

### Python Functionality

- The Python modules within the `functions/postgres_single_user_rotator/psycopg2` directory provide necessary functionality for interacting with PostgreSQL databases.
- These modules likely handle database connection, querying, and other operations required for rotating secrets.

### Terraform Configuration

- Terraform resources in `main.tf` orchestrate the setup of the Lambda function and its associated IAM roles and policies for secret rotation.
- The configuration ensures that the Lambda function has the necessary permissions to rotate RDS secrets securely.

## subnet_group

### Directory Structure
- `main.tf`: Defines Terraform resources for creating an RDS subnet group.
  - Uses local variables to define the name of the subnet group.
  - Creates an `aws_db_subnet_group` resource with the specified name, description, subnet IDs, and tags.
  - The resource is conditionally created based on the value of the `create` variable.

### Terraform Configuration
- The Terraform configuration in `main.tf` is responsible for creating an RDS subnet group.
- It utilizes the `aws_db_subnet_group` resource to define the subnet group with the specified attributes.
- The resource is created conditionally based on the value of the `create` variable, allowing for dynamic management of the subnet group's existence.
- Tags are added to the subnet group for identification and organization purposes.

### Purpose
- This module encapsulates the logic for managing RDS subnet groups, allowing for easy creation and management of these groups within AWS RDS environments.
- Subnet groups are essential for defining the subnets in which RDS instances can be launched, ensuring proper network configuration and security.

## Outputs

- **identifier_name** : Outputs the RDS instance identifier name.
- **security_group_id** : Outputs the security group ID.
- **db_port** : Outputs the RDS instance port.
- **address** : Outputs the RDS instance address.
- **endpoint** : Outputs the RDS instance endpoint.
- **connection_string** : Outputs the RDS instance connection string.
- **username** : Outputs the RDS instance username.
- **initial_db_name** : Outputs the initial RDS instance database name.

