# ecs-fargate-service

## Overview

- Retrieves the AWS account ID and region using data sources and assigns them to local variables.
- Defines an IAM role (aws_iam_role.ecs_task_role) for ECS tasks with permissions to access AWS resources.
- Configures the IAM role's assume role policy to allow ECS tasks to assume the role.
- Defines an IAM policy (aws_iam_policy.service_task_execution_policy) with statements allowing specific actions related to AWS Systems Manager (SSM).
- This policy is attached to the ECS task role using aws_iam_role_policy_attachment.
- Configures an ECS task definition (aws_ecs_task_definition.service_task) with specifications such as family, network mode, CPU, memory, execution role, task role, container definitions, and volume configurations.
- Creates an ECS service (aws_ecs_service.service) with parameters like service name, cluster name, desired count, network configuration, capacity provider strategy, load balancer configurations, and tags.
- Enables execute command feature for ECS service.
- Conditionally, includes an auto-scaling module (module.scale_configuration) based on the value of the scale_service variable.
- Passes relevant parameters to the auto-scaling module, including ECS cluster name, ECS service name, auto-scaling metric type, permissible value, minimum and maximum capacity.

## auto-scaling

- Defines local variables for the resource ID and policy name, based on the ECS cluster name and service name.
- Creates an `aws_appautoscaling_target` resource (`ecs_target`) to specify the auto-scaling target for the ECS service.
- Configures minimum and maximum capacities, resource ID, scalable dimension (`"ecs:service:DesiredCount"`), service namespace (`"ecs"`), and tags.
- Creates an aws_appautoscaling_policy resource (`cpu_target`) for CPU-based auto-scaling.
- The policy is conditionally created based on the value of the `metric_type` variable being set to "CPU."
- Configures the policy name, type, resource ID, scalable dimension, service namespace, and the target tracking scaling policy configuration.
- The target value is set based on the `permissible_value` variable, and the predefined metric type is `"ECSServiceAverageCPUUtilization."`
- Creates an `aws_appautoscaling_policy` resource (`memory_target`) for memory-based auto-scaling.
- The policy is conditionally created based on the value of the `metric_type` variable being set to `"MEMORY."`
- Configures the policy name, type, resource ID, scalable dimension, service namespace, and the target tracking scaling policy configuration.
- The target value is set based on the permissible_value variable, and the predefined metric type is `"ECSServiceAverageMemoryUtilization."`
