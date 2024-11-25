variable "vpc_name" {
  type     = string
}
variable "vpc_cidr" {
  type     = string
}
variable "web_subnets" {
  type     = list
}
variable "app_subnets" {
  type    = list
}
variable "data_subnets" {
  type     = list
}
variable "web_nacl_rules" {
  type    = any
}
variable "app_nacl_rules" {
  type    = any
}
variable "data_nacl_rules" {
  type    = any
}
variable "dns_domain_name" {
  type      = string
}

/* Environment Tags */
variable "aws_region" {
  type     = string
}
variable "Environment" {
  type      = string
}
variable "BusinessUnit" {
  type      = string
}
variable "Maintainer" {
  type     = string
}
variable "ApplicationSuite" {
  type = string
  default = "Networking"
}
variable "Scope" {
  type    = string
}
variable "Schedule" {
  type = string

}
variable "CreatedBy" {
  type    = string
  default = "Terraform"
}

variable "app_static_route_table_associations" {
  type    = list(map(string))
  default = []
}
variable "data_static_route_table_associations" {
  type    = list(map(string))
  default = []
}
variable "log_retention_in_days" {
  type    = number
  default = 30
}
