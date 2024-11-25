output "id" {
  value = aws_vpc.this.id
}
output "internet_gateway_id" {
  value = aws_internet_gateway.vpc_internet_gateway.id
}
output "cidr_block" {
  value = aws_vpc.this.cidr_block
}
output "vpc_name" {
  value = aws_vpc.this.tags.Name
}
output "hosted_zone_id" {
  value = aws_route53_zone.private.zone_id
}
//Outputs saved other than module to ssm
resource "aws_ssm_parameter" "vpc_id" {
  name                       = "/network/${var.vpc_name}/vpc_id"
  value                      = aws_vpc.this.id
  type                       = "String"
  tags                       = {"Name": "${var.vpc_name}-vpc_id"}
}
resource "aws_ssm_parameter" "vpc_name" {
  name                       = "/network/${var.vpc_name}/vpc_name"
  value                      = aws_vpc.this.tags.Name
  type                       = "String"
  tags                       = {"Name": "${var.vpc_name}-vpc_name"}
}
resource "aws_ssm_parameter" "cidr_block" {
  name                       = "/network/${var.vpc_name}/cidr_block"
  value                      = aws_vpc.this.cidr_block
  type                       = "String"
  tags                       = {"Name": "${var.vpc_name}-cidr_block"}
}
resource "aws_ssm_parameter" "zone_id" {
  name                       = "/network/${var.vpc_name}/zone_id"
  type                       = "String"
  value                      = aws_route53_zone.private.zone_id
  tags                       = {"Name": "${var.vpc_name}-zone_id"}
}
resource "aws_ssm_parameter" "domain_name" {
  name                       = "/network/${var.vpc_name}/domain_name"
  type                       = "String"
  value                      = var.dns_domain_name
  tags                       = {"Name": "${var.vpc_name}-domain_name"}
}