variable "AWS_REGION" {
  type          = string
  description   = "AWS Region"
}

variable "AWS_PROFILE" {
  type          = string
  default       = "default"
}

variable "PRIVATE_NETWORKS" {
  type          = list
}
variable "VPC_ID" {
  type          = string
}

variable "TAGS" {
  type          = object({})
}
variable "PUBLIC_SUBNET_IDS"  {
  type          = list
}