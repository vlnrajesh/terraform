variable db_identifier_name {
  type              = string
  description       = "Database identifier name to be passed"
}
variable "create" {
  type              = bool
  description       = "Optional, used for group/re-group security groups"
  default           =  true
}
variable "engine_name" {
  type              = string
}
variable "major_engine_version" {
  type              = string
}
variable "options" {
  type              = list(map(string))
  default = []
}