variable "cluster_name" {
  type        = string
}
variable "oidc_issuer" {
  type        = string
}

variable "Environment" {
  type        = string
}
variable "namespace" {
  description = "Namespace where ALB Controller will be created"
  type        = string
  default     = "kube-system"
}
variable "parameter_prefix" {
  type        = string
  default     = ""
}
variable "service_account_name" {
  description = "Service Account Name for ALB Controller"
  type        = string
  default     = "secrets-store-csi-driver"
}
variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to helm chart"
}
variable "helm_chart_version" {
  description = "Version for Helm Chart, not Application Version, https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller"
  type        = string
  default     = "1.3.4"
}