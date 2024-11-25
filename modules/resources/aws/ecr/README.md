# ecr

This Terraform module creates an Amazon Elastic Container Registry (ECR) repository with configurable retention policies and lifecycle rules.

## Overview

- Utilizes the `aws_caller_identity` and `aws_region` data sources to fetch the AWS account ID and the current AWS region.
- Declares local variables account_id and region for use within the module.
- Defines an `aws_ecr_repository` resource named repository_name.
- Configures the ECR repository with the provided variables such as repository name, image tag mutability, and image scanning configuration.
- Enables force delete and associates tags with the repository.
- Creates an `aws_ecr_lifecycle_policy` resource named `life_cycle_policy`.
- Defines a lifecycle policy using JSON encoding with rules for expiring images based on conditions such as untagged images older than a specified number of days and tagged images exceeding a certain count.

## Outputs

- **ecr_repo_url** : Provides the ECR repository URL with specified image tag.
- **name** : Provides the ECR repository name without the image tag.

