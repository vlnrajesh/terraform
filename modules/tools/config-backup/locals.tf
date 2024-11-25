data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  lambda_src_path         = "${path.module}/../../../lambda-functions/${var.lambda_function_name}"
  lambda_dest_path        = "${path.module}/../../../lambda-functions/${var.lambda_function_name}.zip"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  cleaned_relative_path       = replace(path.module,"../","")
  resource_path               = replace(local.cleaned_relative_path,"^/+","")
}
