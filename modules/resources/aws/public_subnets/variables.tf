variable "Environment" {
  type      = string
}
variable "subnets" {
  type     = list
}
variable "vpc_id" {
  type     = string
}
variable "vpc_name" {
  type     = string
}
variable "internet_gateway_id" {
  type      = string
}
variable "nacl_rules" {
  type      = map(map(string))
}
variable tags {
  type      = map(string)
  default = {}
}