
variable "lambda_function_name" {
  description         = "Lambda function name to deploy"
  type                = string
}
variable "security_group_id" {
  description         = "Subnet id for deploying Lambda"
  type                = string
}
variable "subnets" {
  description         = "Subnets to deploy Lambda function"
  type                = list(string)
}
variable "secret_id" {
  type                = string
}
variable "identifier_name" {
  description         = "RDS identifier name"
  type                = string
}
variable "rotation_days" {
  description         = "Password rotation for RDS"
  type                = number
  default             = 60
}
variable "memory_size" {
  type          = number
  default       = 1024
}
variable "timeout" {
  type          = number
  default       = 900
}
variable "runtime" {
  type          = string
  default       = "python3.9"
}