data "aws_ssm_parameter" "vpc_id" {
  name                 = "/network/${var.vpc_name}/vpc_id"
}

data "aws_ssm_parameter" "app_subnet_ids" {
  name                 = "/network/${var.vpc_name}/app_subnets"
}
locals {
  vpc_id                  = data.aws_ssm_parameter.vpc_id.value
  private_subnets         = split(",",data.aws_ssm_parameter.app_subnet_ids.value)
}

module "config-backup" {
  source                  = "../../../modules/tools/config-backup"
  subnets                 = nonsensitive(toset(local.private_subnets))
  vpc_id                  = local.vpc_id
}