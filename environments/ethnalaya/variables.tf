variable "AWS_REGION" {
  type          = string
  default       = "us-east-2"
}

variable "AWS_PROFILE" {
  type          = string
  default       = "default"
}
variable "CIDR" {
  type          = string
}

variable "VPC_NAME" {
  type          = string
}
variable "ENVIRONMENT" {
  type          = string
}
variable "COSTCENTER" {
  type          = string
}
variable "MAINTAINER" {
  type           = string
}
variable "SOURCE" {
  type          = string
}
variable "PRIVATE_SUBNETS" {
  type          = list
}
variable "PUBLIC_SUBNETS" {
  type          = list
}
