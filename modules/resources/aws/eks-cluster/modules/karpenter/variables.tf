variable "create_karpenter" {
  type          = bool
  default       = true
}
variable "cluster_name" {
  type          = string
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
variable "private_subnets" {
  type         = list(string)
}
variable "additional_tags" {
  type        = any
}
variable "node_class_name" {
  type          = string
}
variable "node_pool_name" {
  type          = string
}
variable "ami_family" {
  type         = string
  default      = "Bottlerocket"
}
variable "iam_role" {
  type         = string
}
variable "architectures" {
  type         = list(string)
  default      = ["x86_64", "amd64"]
}
variable "operating_systems" {
  type         = list(string)
  default      = ["linux"]
}
variable "capacity_type" {
  type         = string
  default      = "spot"
}
variable "instance_category" {
  type        = list(string)
  default     =  ["c", "m", "r"]
}
variable "disruption_in_hours" {
  type        = number
  default     = 240
}
variable "cpu_limit" {
  type        = number
  default     = 100
}
variable "memory_limit" {
  type        = number
  default     = 100
}
variable "consolidation_in_seconds" {
  type        = number
  default     = 60
}
variable "weight" {
  type        = number
  default     = 1
}
variable "node_labels" {
  description = "A map of labels to apply to the NodeClass"
  type        = map(string)
  default     = {}
}
variable "instancePool" {
  type        = string
}