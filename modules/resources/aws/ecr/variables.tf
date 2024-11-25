variable "repository_name" {
  description   =  "Name of the repository"
  type          = string
}
variable "tag_prefix" {
  description   = "prefix tag to be added to image retention policy"
  type          = string
}
variable "image_tag_mutability" {
  description   = "Image can be mutable or immutable. immutable immages cannot be re-tagged"
  type          = string
  default       = "MUTABLE"
}
variable "retention_policy" {
  description   = "Image retention rules"
  type          = any
  default = {
    "tagged"    = 5
    "untagged"  = 14
  }
}
variable "image_tag" {
  description   = "Default image tag if not provided"
  type        = string
  default     = "latest"
}