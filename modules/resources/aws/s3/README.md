# s3

This Terraform module creates an Amazon S3 bucket with associated configurations.

## Overview

- Defines an S3 bucket resource (`aws_s3_bucket.bucket_resource`) with the specified bucket name and optional region.
- Tags the S3 bucket with a `"Name"` tag using the provided variable.
- Configures public access block settings for the S3 bucket using `aws_s3_bucket_public_access_block`.
- Blocks various types of public access to the S3 bucket, enhancing security.
- Defines a lifecycle configuration for the S3 bucket (`aws_s3_bucket_lifecycle_configuration.bucket_lifecycle`).
- Sets a rule for object expiration, specifying the number of days after which objects should be deleted.
- Creates an IAM policy (`aws_iam_policy.bucket_policy`) that defines permissions for S3 bucket operations.
- Grants permissions for PutObject, GetObject, and DeleteObject actions on objects within the bucket.
- Allows listing the bucket content (ListBucket action).
- Attaches the IAM policy to a specified IAM role (`aws_iam_role_policy_attachment.bucket_policy_attachment`).
- Associates the IAM role with the defined S3 bucket policy, granting the specified permissions.

## Outputs

- **bucket_name** : Outputs the name of the created S3 bucket.
- **bucket_arn** : Outputs the Amazon Resource Name (ARN) of the created S3 bucket.