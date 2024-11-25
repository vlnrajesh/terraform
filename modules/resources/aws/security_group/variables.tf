
variable "security_group_name" {
  type            = string
  description     = "Security group name"
}
variable "description" {
  type          = string
  default       = "Default description for security group"
}
variable "vpc_id" {
  type          = string
}