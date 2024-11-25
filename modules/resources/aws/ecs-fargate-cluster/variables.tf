variable "cluster_name" {
  type          = string
  description   = "ECS cluster name which appears while listing clusters"
}
variable "log_retention_in_days" {
  type          = number
  description   = "Number of days the cloudwatch service and cluster logs to retain"
  default       = 30
}
variable "capacity_provider" {
  type          = string
  description   = "Capacity provider for cluster, allowed values were FARGATE,FARGAET_SPOT"
  default       = "FARGATE"
}
variable "container_insights" {
  type          = string
  description   = "To enable container monitoring for ECS, cost associated to it would be the data published to cloudwatch"
  default       = "disabled"
}