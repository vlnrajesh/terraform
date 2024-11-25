terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region                   = var.aws_region
  default_tags {
    tags = {
      Environment         = var.Environment
      BusinessUnit        = var.BusinessUnit
      Maintainer          = var.Maintainer
      ApplicationSuite    = var.ApplicationSuite
      Schedule            = var.Schedule
      CreatedBy           = var.CreatedBy
    }
  }
}

