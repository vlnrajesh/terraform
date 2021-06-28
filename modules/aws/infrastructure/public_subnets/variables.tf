variable "AWS_REGION" {
  type          = string
  description   = "AWS Region"
}

variable "AWS_PROFILE" {
  type          = string
  default       = "default"
}

variable "PUBLIC_SUBNETS" {
  type          = list
}
variable "VPC_ID" {
  type          = string
}

variable "TAGS" {
  type          = object({})
}
variable "INTERNET_GATEWAY_ID" {
  type          = string
}