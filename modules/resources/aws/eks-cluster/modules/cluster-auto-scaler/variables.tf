variable "node_group_name" {
  type        =  string
}
variable "cluster_name" {
  type  = string
}
variable "node_role_arn" {
  type  = string
}
variable "node_role_name" {
  type  = string
}
variable "subnets" {
  type  = list(string)
}
variable "volume_type" {
  type        = string
  default     = "gp3"
}
variable "release_version" {
  type        = string
}
variable "enable_monitoring" {
  type        = bool
  default     = false
}
variable node_security_group_id {
  type        = list(string)
}

variable "ami_type" {
  description     = "EKS optimised AMI, preferred options are BOTTLEROCKET_x86_64 and AL2_x86_64"
  type            = string
  default         = "BOTTLEROCKET_x86_64"
}
variable "instance_group" {
  description     = "Instance types configured for node-group, Refer Instance class types for more details"
  type            = string
  default         = "2C4G"
}
variable "capacity_type" {
  description     = "Type of capacity associated with the EKS Node Group"
  type            = string
  default         = "ON_DEMAND"
}
variable "disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = 8
}
variable "desired_size" {
  description = "update an Auto Scaling Group of Kubernetes worker nodes compatible with EKS for desired number of hosts"
  type = number
  default = 1
}
variable "max_size" {
  description = "update an Auto Scaling Group of Kubernetes worker nodes compatible with EKS for maximum number of hosts"
  type  = number
  default = 1
}
variable "min_size" {
  description = "update an Auto Scaling Group of Kubernetes worker nodes compatible with EKS for minimum number of hosts"
  type = number
  default = 1
}
variable "update_percentage" {
  description = "Desired max percentage of unavailable worker nodes during node group update"
  type        = number
  default     = 33
}
variable "use_custom_launch_template" {
  type        = bool
  default     = false
}
variable "taints" {
  type        = any
  default     = {}
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
variable "additional_tags" {
  type      = any
}
variable "labels" {
  type      = map(string)
}