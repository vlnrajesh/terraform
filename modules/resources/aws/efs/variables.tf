variable "efs_name" {
  type        = string
  description = "The name of the Amazon EFS (Elastic File System) volume"
}

variable "encrypted" {
  type        = bool
  default     = true
  description = "Indicates whether the Amazon EFS volume is encrypted"
}

variable "performance_mode" {
  type        = string
  default     = "generalPurpose"
  description = "The performance mode of the Amazon EFS volume"
}

variable "throughput_mode" {
  type        = string
  default     = "bursting"
  description = "The throughput mode of the Amazon EFS volume"
}

variable "subnets" {
  type        = list(string)
  description = "The list of subnet IDs in which the Amazon EFS volume will be created"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC (Virtual Private Cloud) where the Amazon EFS volume will be created"
}

variable "port" {
  type        = number
  default     = 2049
  description = "The port number used for communication with the Amazon EFS volume"
}

variable "create_eks_storage_components" {
  type        = bool
  default     = false
  description = "Indicates whether to create storage components for Amazon EKS (Elastic Kubernetes Service)"
}

variable "storage_class_name" {
  type        = string
  default     = "efs.csi.aws.com"
  description = "The name of the storage class for the Amazon EFS volume"
}

variable "storage_capacity" {
  type        = number
  default     = 10
  description = "The storage capacity (in GiB) of the Amazon EFS volume"
}

variable "volume_reclaim_policy" {
  type        = string
  default     = "Retain"
  description = "The volume reclaim policy for the Amazon EFS volume"
}