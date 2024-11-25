data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  cleaned_relative_path   = replace(path.module,"../","")
  resource_path           = replace(local.cleaned_relative_path,"^/+","")
  default_helm_values = {
    "clusterName"         = var.cluster_name
    "serviceAccount.name" = var.service_account_name

    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.this.arn
  }
  helm_values = merge(local.default_helm_values, var.settings)
}