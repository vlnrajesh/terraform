# ecs-fargate-cluster

## Overview

- Configures TFLint with settings related to modules and plugin configurations, particularly for the AWS provider.
- Utilizes the `aws_caller_identity` and `aws_region` data sources to fetch the AWS account ID and the current AWS region.
- Declares local variables for the AWS account ID and region for use within the module.
- Defines an IAM role (`aws_iam_role.ecs_execution_role`) for ECS task execution.
- Specifies a trust policy allowing ECS tasks (`ecs-tasks.amazonaws.com`) to assume the role.
- Creates an IAM policy (`aws_iam_policy.ecs_task_execution_iam_policy`) with statements allowing actions related to Amazon ECR and CloudWatch Logs.
- The policy is attached to the IAM role.
- Defines a CloudWatch Log Group (`aws_cloudwatch_log_group.ecs_cluster_log_group`) for ECS cluster logs.
- Specifies the log group name, retention period, and tags.
- Creates an ECS cluster (`aws_ecs_cluster.ecs_cluster`) with the specified name and settings.
- The containerInsights setting enables CloudWatch Container Insights.
- Tags the ECS cluster with a name.
- Configures ECS cluster capacity providers (aws_ecs_cluster_capacity_providers.cluster_capacity) for Fargate launch type.
- Specifies the capacity providers, default capacity provider strategy, and the cluster to associate them with.


