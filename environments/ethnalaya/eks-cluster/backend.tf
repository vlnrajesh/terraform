terraform {
  backend "s3" {
    key   = "eks-cluster.tfstate"
  }
  required_version = ">= 1.5.7"
}