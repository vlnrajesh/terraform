variable "name" {
  description = "Name of the EKS Fargate Profile"
  type        = string
}
variable "selectors" {
  description = "Configuration block(s) for selecting Kubernetes Pods to execute with this EKS Fargate Profile"
  type        = any
  default     = {}
}
variable "subnets" {
  description = "Identifiers of private EC2 Subnets to associate with the EKS Fargate Profile"
  type        = list(string)
}
variable "cluster_name" {
  type        = string
}
variable "iam_role_arn" {
  type        = string
}