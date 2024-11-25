variable "cluster_name" {
  type        = string
}
variable "oidc_issuer" {
  type        = string
}
variable "aws_account_id" {
  type        = number
}
variable "namespace" {
  description = "Namespace where ALB Controller will be created"
  type        = string
  default     = "kube-system"
}
variable "addon_version" {
  type       = string
  default    = "v2.0.4-eksbuild.1"
}