variable "cluster_name" {
  description   = "cluster name for the EKS"
  type          = string
}
variable "cluster_version" {
  type         = string
  default      = "1.30"
}
variable "log_retention_in_days" {
  description   = "number of days the logs to retain"
  type          = number
  default       = 3
}
variable "cluster_endpoint_public_access" {
  description   = "Whether cluster need to be accessed from public subnet"
  type          = bool
  default       = true
}
variable "cas_groups" {
  description   = "Node configuration for the cluster"
  type          = any
}
variable "create_ec2_nodes" {
  description   = "Whether to create node group"
  type          = bool
  default       = true
}
variable "create_karpenter_node_group" {
  description   = "Whether to create node group"
  type          = bool
  default       = true
}
variable "create_fargate_profile" {
  description = "Whether to create fargate profile"
  type        = bool
  default     = false
}
variable "alb_ingress_controller" {
  description = "ALB Ingress controller"
  type        = bool
  default     = false
}
variable "efs_csi_driver" {
  description = "EFS CSI driver for EKS"
  type        = bool
  default     = false
}
//External variables
variable "vpc_id" {
  type          = string
}
variable "vpc_cidr" {
  type          = string
}
variable "public_subnets" {
  type          = list(string)
}
variable "private_subnets" {
  type         = list(string)
}
variable "Environment" {
  type      = string
}
variable "BusinessUnit" {
  type      = string
}
variable "CreatedBy" {
  type      = string
}
variable "fargate_profiles" {
  type      = any
}
variable "secrets-store-csi" {
  type      = bool
  default   = false
}
variable "autoscale_interval" {
  description = "How often cluster is reevaulated for scale up and down"
  type        = number
  default     = 10
}
variable "karpenter_pools" {
  description   = "Node configuration for the cluster"
  type          = any
}
variable "karpenter_replicas" {
  description = "No of karpenter pod instances to run"
  type        = number
  default     = 2
}
variable "karpenter_namespace" {
  description = "Default namespace for karpenter"
  type        = string
  default     = "karpenter"
}