module "vpc" {
  source                  = "../../../modules/resources/aws/vpc"
  vpc_name                = var.vpc_name
  cidr_block              = var.vpc_cidr
  dns_domain_name         = var.dns_domain_name
  Environment             = var.Environment
  log_retention_in_days   = var.log_retention_in_days

}
module "web_subnets" {
  depends_on              = [module.vpc]
  source                  = "../../../modules/resources/aws/public_subnets"
  vpc_id                  = module.vpc.id
  vpc_name                = module.vpc.vpc_name
  internet_gateway_id     = module.vpc.internet_gateway_id
  subnets                 = var.web_subnets
  nacl_rules              = var.web_nacl_rules
  Environment             = var.Environment
}
module "app_subnets" {
  depends_on              = [module.vpc]
  source                  = "../../../modules/resources/aws/private_subnets"
  Environment             = var.Environment
  subnets                 = var.app_subnets
  vpc_id                  = module.vpc.id
  vpc_name                = module.vpc.vpc_name
  nacl_rules              = var.app_nacl_rules
  eip_allocation_subnets  = module.web_subnets.subnet_ids
  single_nat_gateway      = true
  vpc_cidr                = module.vpc.cidr_block
  static_route_table_associations = var.app_static_route_table_associations
}
#module "data_subnets" {
#  depends_on              = [module.vpc]
#  source                  = "../../../modules/resources/aws/private_subnets"
#  Environment             = var.Environment
#  subnets                 = var.data_subnets
#  vpc_id                  = module.vpc.id
#  vpc_name                = module.vpc.vpc_name
#  nacl_rules              = var.data_nacl_rules
#  eip_allocation_subnets  = module.web_subnets.subnet_ids
#  nat_gateway_ids         = module.app_subnets.nat_gateway_ids
#  single_nat_gateway      = true
#  vpc_cidr                = module.vpc.cidr_block
#  static_route_table_associations = var.data_static_route_table_associations
#}
