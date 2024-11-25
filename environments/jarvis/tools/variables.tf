variable "vpc_name" {
  type      = string
}
variable "Environment" {
  type      = string
}

/* Environment Tags */
variable "Maintainer" {
  type     = string
}
variable "ApplicationSuite" {
  type = string
  default = "Tools application suite"
}
variable "aws_region" {
  type     = string
}
variable "BusinessUnit" {
  type        = string
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