data "aws_ssm_parameter" "vpc_id" {
  name      = "/network/${var.vpc_name}/vpc_id"
}
data "aws_ssm_parameter" "vpc_cidr" {
  name      = "/network/${var.vpc_name}/cidr_block"
}
data "aws_ssm_parameter" "public_subnet_ids" {
  name      = "/network/${var.vpc_name}/public_subnets"
}
data "aws_ssm_parameter" "app_subnet_ids" {
  name      = "/network/${var.vpc_name}/app_subnets"
}
locals {
  vpc_id                  = data.aws_ssm_parameter.vpc_id.value
  vpc_cidr                = data.aws_ssm_parameter.vpc_cidr.value
  cluster_name            = "${var.Environment}-eks-cluster"
  public_subnets          = split(",",data.aws_ssm_parameter.public_subnet_ids.value)
  private_subnets         = split(",", data.aws_ssm_parameter.app_subnet_ids.value)
}
module "eks-cluster" {
  source                  = "../../../modules/resources/aws/eks-cluster"
  cluster_name            = local.cluster_name
  vpc_id                  = local.vpc_id
  vpc_cidr                = local.vpc_cidr
  public_subnets          = nonsensitive(toset(local.public_subnets))
  private_subnets         = nonsensitive(toset(local.private_subnets))
  BusinessUnit            = var.BusinessUnit
  Environment             = var.Environment
  create_ec2_nodes        = var.create_node_group
  cas_groups              = var.cas_groups
  create_fargate_profile  = var.create_fargate_profile
  fargate_profiles        = var.fargate_profiles
  alb_ingress_controller  = var.alb_ingress_controller
  efs_csi_driver          = var.efs_csi_driver
  secrets-store-csi       = var.secrets-store-csi
  CreatedBy               = var.CreatedBy
  autoscale_interval      = var.autoscale_interval
  karpenter_pools         = var.karpenter_pools
  karpenter_replicas      = 1
}