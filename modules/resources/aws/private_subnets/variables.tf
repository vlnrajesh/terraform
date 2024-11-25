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
variable "vpc_cidr" {
  type     = string
}
variable "eip_allocation_subnets" {
  type     = list
  default  = []
}
variable "multiple_nat_gateway" {
  type     = bool
  default  = false
}
variable "nat_gateway_ids" {
  type      = list
  default   = []
}
variable "nacl_rules" {
  type      = map(map(string))
}

variable "single_nat_gateway" {
  type      = bool
  default   = false
}
variable "gateway_endpoints" {
  type      = list(string)
  default = ["s3", "dynamodb"]
}
variable "static_route_table_associations" {
  type      = list(map(string))
}