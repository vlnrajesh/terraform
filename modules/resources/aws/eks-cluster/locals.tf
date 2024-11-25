data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
locals {
  account_id                = data.aws_caller_identity.current.account_id
  cluster_name              = aws_eks_cluster.this.name
  openid_connector_provider = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://","")
  region                    = data.aws_region.current.name
  cleaned_relative_path     = replace(path.module,"../","")
  resource_path              = replace(local.cleaned_relative_path,"^/+","")
}
