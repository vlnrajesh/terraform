variable service_name {
    description = "service name defined for the sonarqube server"
    type = string
    default = "sonarqube"
}
variable cpu {
  description   = "maximum cpu utilized by the sonarqube service"
  type          = number
  default       = 2048
}
variable memory {
  description   = "maximum memory utilized by the sonarqube service"
  type          = number
  default       = 4096
}
variable sonarqube_app_port {
  description   = "sonarqube application port"
  type          = number
  default       = 9000
}
variable container_image {
  description   = "base image used for deploying sonarqube service"
  type          = string
  default       = "sonarqube:latest"
}
variable "desired_service_count" {
  description   = "desired number of instances of the service to run"
  type          = number
  default       = 1
}
variable plugins_home {
  description   = "persistence location for storing plugin information"
  type          = string
  default       = "/opt/sonarqube/extensions/plugins"
}
variable "sonarqube_domain_name" {
  description = "Public accessible URL"
  type        = string
}
variable efs_port {
  description = "default EFS access port"
  type = number
  default = 2049
}

variable vpc_id {
  type  = string
}
variable efs_id {
  type  = string
}
variable efs_security_group_id {
  type  = string
}
variable load_balancer_arn {
  type  = string
}
variable acm_certificate_arn {
  type  = string
}
variable "load_balancer_security_group_id" {
  type = string
}
variable rds_security_group_id {
  type = string
}
variable "rds_db_port" {
  type = number
}
variable "rds_initial_db_name"{
  type = string
}
variable cluster_name {
  type = string
}
variable cloudwatch_log_group_name {
  type = string
}
variable subnets {
  type = list(string)
}
variable rds_username {
  type = string
}
variable connection_string{
  type = string
}
variable identifier_name {
  type = string
}
variable ecs_execution_role_name {
  type = string
}
variable ecs_execution_role_arn {
  type = string
}
