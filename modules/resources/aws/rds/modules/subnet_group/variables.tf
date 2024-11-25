variable db_identifier_name {
  type              = string
  description       = "Database identifier name to be passed"
}
variable "create" {
  type              = bool
  description       = "Optional, used for group/re-group security groups"
  default           =  true
}
variable "subnet_ids" {
  type              = list(string)
  description       = "list of subnet ids to be added to subnet ids"
}