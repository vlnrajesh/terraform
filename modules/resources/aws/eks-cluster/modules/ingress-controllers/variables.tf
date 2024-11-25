variable "cluster_name" {
  type        = string
}

variable "oidc_provider" {
  type        = string
}
variable "namespace" {
  description = "Namespace where ALB Controller will be created"
  type        = string
  default     = "kube-system"
}
variable "service_account_name" {
  description = "Service Account Name for ALB Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to helm chart"
}