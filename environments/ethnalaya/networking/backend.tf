terraform {
  backend "s3" {
    key   = "networking.tfstate"
  }
  required_version = ">= 1.5.7"
}