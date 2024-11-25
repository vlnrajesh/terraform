variable "bucket_name" {
  description   = "S3 bucket name"
  type          = string
}
variable "expiration_in_days" {
  description   = "Delete objects older than specified days"
  type          = number
  default       = 0
}
variable "bucket_region" {
  type          = string
  description   = "S3 bucket region"
}
variable "iam_role_name" {
  type          = string
}