# Elastic File system

Designed to create and manage an AWS Elastic File System (EFS) along with related resources. It allows you to provision EFS with configurable options such as encryption, performance mode, and throughput mode.

## Overview

- Retrieves the AWS account ID and region using data sources and assigns them to local variables.
- Creates an EFS file system (`aws_efs_file_system.efs`) with specified attributes such as creation token, encryption, throughput mode, and performance mode.
- Optionally, defines an IAM policy document (`data.aws_iam_policy_document.efs_resource_policy`) to control access to the EFS file system.
- If `var.create_eks_storage_components` is false, it creates an IAM policy (`aws_iam_policy.resource_access_policy`) allowing specific EFS actions and attaches it to the EFS file system.
- Optionally, creates an EFS file system policy (`aws_efs_file_system_policy`) using the IAM policy document.
- Invokes a security group module (`module.efs_security_group`) to create a security group for the EFS file system.
- Creates EFS mount targets (`aws_efs_mount_target`) in each specified subnet, associating them with the EFS file system and the security group created.
- If var.create_eks_storage_components is true, it creates a Kubernetes storage class (`kubernetes_storage_class`) and persistent volume (`kubernetes_persistent_volume`) for EFS-based storage provisioning.

## Outputs

- **id**: The ID of the created EFS file system.
- **security_group_id**: The ID of the security group associated with the EFS file system.
- **volume_arn**: The ARN of the created EFS file system.
- **efs_iam_access_policy_arn**: The ARN of the IAM policy allowing access to the EFS file system.
- **name**: The name of the EFS file system.
- **storage_class_name**: The name of the storage class for Kubernetes.