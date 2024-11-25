data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
locals {
  cleaned_relative_path     = replace(path.module,"../","")
  resource_path             = replace(local.cleaned_relative_path,"^/+","")
  account_id                = data.aws_caller_identity.current.account_id
  region                    = data.aws_region.current.name
  instance_class_types      = jsondecode(file("${path.module}/instance_class.json"))
}