variable "load_balancer_name" {
  description   = "Name of the load balancer"
  type          = string
}
variable "internal_load_balancer" {
  description     = "Type of load balancer, whether it is internal or external"
  type            = bool
  default         = false
}
variable "create_http_listener" {
  description     = "Choose whether to create an http listener"
  type            = bool
  default         = true
}
variable "create_https_listener" {
  description     = "Choose whether to create an https listener"
  type            = bool
  default         = true
}
variable "default_action" {
  description      = "the default action passed as dynamic variable for https listener"
  type             = list(any)
  default          = []
}
/* Module level variables */
variable "acm_certificate_arn" {
  description      = "AWS certification manager ARN dictionaries"
  type             = string
}
variable "vpc_id" {
  description     = "VPC id to create load balancer subnet group"
  type            = string
}
variable "subnets" {
  description     = "Subnet list for creating application load balancer"
  type            = list(string)
}
