variable db_identifier_name {
  type              = string
  description       = "Database identifier name to be passed"
}
variable "create" {
  type              = bool
  description       = "Optional, used for creating db parameter group"
  default           =  true
}
variable "family" {
  type      = string
}
variable "parameters" {
  description = "A list of DB parameter maps to apply"
  type        = list(map(string))
  default     = []
}