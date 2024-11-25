variable "Environment" {
  type     = string
}
variable "vpc_name" {
  type     = string
}
variable "cidr_block" {
  type     = string
}
variable "enable_dns_support" {
  type      = bool
  default   = true
}
variable "enable_dns_hostnames" {
  type      = bool
  default   = true
}
variable "dns_domain_name" {
  type      = string
}
variable "enable_vpc_flow_logs"{
  type     = bool
  default  = true
}
variable "log_retention_in_days" {
  type      = number
  default   = 30
}
variable "additional_vpc_ids" {
  type      = list(string)
  default   = []
}
variable "traffic_type" {
  type      = string
  default   = "ALL"
}