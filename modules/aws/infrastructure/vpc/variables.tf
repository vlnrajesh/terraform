variable "AWS_REGION" {
  type          = string
  default       = "us-east-2"
}

variable "AWS_PROFILE" {
  type          = string
  default       = "default"
}

variable "NAME" {
  type          = string
}

variable "CIDR" {
  type          = string
  default       = "0.0.0.0/0"
}
variable "ENABLE_DNS_SUPPORT" {
  type          = bool
  default       = true
}
variable "ENABLE_DNS_HOSTNAMES" {
  type          = bool
  default       = true
}
variable "TAGS" {
  type          = object({
      Name            = string
      Environment     = string
      CostCenter      = string
      Source          = string
      Maintainer      = string
      Terraformed     = bool
  })
}