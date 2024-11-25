variable "identifier_name" {
  type      = string
}
variable "subnets" {
  type = list(string)
}
variable "instance_class" {
  type      = string
}
variable "family" {
  type      = string
}
variable "engine_name" {
  type      = string
}
variable "engine_version" {
  type      = string
}
variable "publicly_accessible" {
  type      = bool
  default   = false
}
variable "allocated_storage" {
  type      = number
  default   = 5
}
variable "max_allocated_storage" {
  type = number
  default=20
}
variable "storage_encrypted" {
  type    = bool
  default = true
}
variable "port" {
  type    = map(string)
  default = {
    "postgres"    : "5432"
  }
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "backup_retention_period" {
  type    = number
  default = 2
}
variable "db_username" {
  type      = string
  default   = "root"
}
variable "vpc_id" {
  type      = string
}
variable "create_subnet_group" {
  type      = bool
  default   = true
}
variable "create_parameter_group" {
  type      = bool
  default   = true
}
variable "create_option_group" {
  type      = bool
  default   = true
}
variable "db_subnet_group_name" {
  type      = string
  default   = null
}
variable parameter_group_name {
  type      = string
  default   = null
}
variable option_group_name {
  type      = string
  default   = null
}
variable initial_db_name {
  type      = string
  default   = null
}