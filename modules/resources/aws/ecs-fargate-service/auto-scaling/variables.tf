variable ecs_cluster_name {
  description     = "ECS Cluster name which participate in auto scaling"
  type            = string
}
variable ecs_service_name {
  description     = "ECS service name which participate in auto scaling"
  type            = string
}
variable "max_capacity" {
  description     = "Max capacity of the scalable target"
  type            = number
  default         = 0
}
variable "min_capacity" {
  description     = "Min capacity of the scalable target"
  type            = number
  default         = 0
}
variable "metric_type" {
  description     = "Metric type "
  type            = string
}
variable "policy_type" {
  description     = "Policy type. Valid values are StepScaling and TargetTrackingScaling"
  type            = string
  default         = "TargetTrackingScaling"
}
variable "permissible_value" {
  description     = "Allowed value"
  type            = number
  default         = 80
}