terraform {
  backend "s3" {
    key   = "tools.tfstate"
  }
  required_version = ">= 1.5.7"
}
