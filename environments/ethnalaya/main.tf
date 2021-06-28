module "vpc" {
  source          = "../../modules/aws/infrastructure/vpc"
  CIDR            = var.CIDR
  NAME            = var.VPC_NAME
  TAGS            = {
                  Name            = var.VPC_NAME
                  Environment     = var.ENVIRONMENT
                  CostCenter      = var.COSTCENTER
                  Source          = var.SOURCE
                  Maintainer      = var.MAINTAINER
                  Terraformed     = true
              }
}
module "public_subnets" {
  source              = "../../modules/aws/infrastructure/public_subnets"
  PUBLIC_SUBNETS      = var.PUBLIC_SUBNETS
  AWS_REGION          = var.AWS_REGION
  VPC_ID              = module.vpc.vpc_id
  INTERNET_GATEWAY_ID = module.vpc.internet_gateway_id
  TAGS                = {
                          Environment     = var.ENVIRONMENT
                          CostCenter      = var.COSTCENTER
                          Source          = var.SOURCE
                          Maintainer      = var.MAINTAINER
                          Terraformed     = true
  }
}
module "private_subnets" {
  source              = "../../modules/aws/infrastructure/private_subnets"
  PRIVATE_NETWORKS    = var.PRIVATE_SUBNETS
  AWS_REGION          = var.AWS_REGION
  VPC_ID              = module.vpc.vpc_id
  PUBLIC_SUBNET_IDS   = module.public_subnets.PUBLIC_SUBNET_IDS
  TAGS                = {
                          Environment     = var.ENVIRONMENT
                          CostCenter      = var.COSTCENTER
                          Source          = var.SOURCE
                          Maintainer      = var.MAINTAINER
                          Terraformed     = true
  }
}
