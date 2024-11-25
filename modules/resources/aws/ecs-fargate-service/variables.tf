variable "service_name" {
  type        = string
  description = "The name of the ECS (Elastic Container Service) service"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC (Virtual Private Cloud) where the ECS service will be deployed"
}

variable "cluster_name" {
  description = "cluster name to associate auto scaling"
  type        = string
}

variable "desired_count" {
  type        = number
  default     = 0
  description = "The desired number of instances of the ECS task to run"
}

variable "subnets" {
  type        = list(string)
  description = "The list of subnet IDs in which to deploy the ECS task"
}

variable "fargate_spot" {
  type        = bool
  default     = false
  description = "Whether to use Fargate Spot instances for the ECS task"
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The retention period (in days) for logs stored in CloudWatch Logs"
}

variable "container_definitions" {
  type        = string
  description = "List of container definition for ecs"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "The ARN (Amazon Resource Name) of the IAM role to be used by ECS task execution"
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "The name of the CloudWatch Logs group where logs from the containers will be sent"
}

variable "cpu" {
  type        = number
  default     = 2048
  description = "The CPU units to be allocated for the ECS task"
}

variable "memory" {
  type        = number
  default     = 4096
  description = "The memory (in MiB) to be allocated for the ECS task"
}

variable "security_group_id" {
  type        = string
  description = "The ID of the security group to associate with the ECS task"
}

variable "volume" {
  type        = any
  default     = {}
  description = "The volume configuration for the ECS task (if any)"
}

variable "load_balancer" {
  type        = any
  default     = {}
  description = "The load balancer configuration for the ECS service (if any)"
}

variable "service_registries" {
  type        = list(any)
  default     = []
  description = "The service discovery registries for the ECS service (if any)"
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Whether to assign a public IP address to the ECS task"
}

variable "scale_service" {
  type        = bool
  default     = false
  description = "whether to scale service"
}

variable "auto_scale_configuration" {
  description = "Auto scaling configuration"
  type = object({
    metric_type       = string
    permissible_value = number
    minimum_capacity  = number
    maximum_capacity  = number
  })
  default = {
    metric_type       = "CPU"
    permissible_value = 80
    minimum_capacity  = 1
    maximum_capacity  = 1
  }
}