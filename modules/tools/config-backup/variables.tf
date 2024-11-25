variable "lambda_function_name" {
  description     = "Name of the Lambda function"
  type            = string
  default         = "config_backup"
}

variable "s3_bucket_prefix" {
  description     = "S3 Buckets for Storing resources"
  type            = string
  default         = "devops-data"
}
variable "memory_size" {
  description     = "Memory constraint for Lambda"
  type            = number
  default         = 1024
}
variable "timeout" {
  description     = "Timeout for Lambda function"
  type            = number
  default         = 300
}

// External variables
variable "vpc_id" {
  description     = "VPC Id for Lambda deployment"
  type            = string
}
variable "runtime" {
  description     = "Runtime environment for Lambda deployment"
  type            = string
  default         = "python3.9"
}
variable "subnets" {
  description     = "Subnet for deployment of lambda"
  type            = list(string)
}