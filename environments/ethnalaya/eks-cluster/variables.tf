variable "vpc_name" {
  type      = string
}
variable "cas_groups" {
  type    = any
}
variable "karpenter_pools" {
  type    = any
}
variable "BusinessUnit" {
  type        = string
}
/* Environment Tags */
variable "aws_region" {
  type     = string
}
variable "Environment" {
  type      = string
}
variable "Maintainer" {
  type     = string
}
variable "ApplicationSuite" {
  type    = string
  default = "EKS-Cluster"
}
variable "Schedule" {
  type = string
}
variable "CreatedBy" {
  type    = string
}
variable "secrets-store-csi" {
  type    = bool
  default = true
}
variable "efs_csi_driver" {
  type    = bool
  default = false
}
variable "alb_ingress_controller" {
  type    = bool
  default = true
}
variable "create_fargate_profile" {
  type    = bool
  default = false
}
variable "create_node_group" {
  type    = bool
  default = true
}
variable "fargate_profiles" {
  type    = any
  default = {}
}
variable "autoscale_interval" {
  type    = string
  default = 10
}