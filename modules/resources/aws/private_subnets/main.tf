data "aws_region" "current" {}
locals {
  nat_gateway_ids = length(var.nat_gateway_ids) == 0 ? aws_nat_gateway.nat_gateway.*.id : var.nat_gateway_ids
  region     = data.aws_region.current.name
}
resource "aws_subnet" "private_subnets" {
  count                     = length(var.subnets)
  vpc_id                    = var.vpc_id
  cidr_block                = lookup(var.subnets[count.index],"cidr")
  availability_zone         = lookup(var.subnets[count.index],"availability_zone")
  map_public_ip_on_launch   = false
  tags                      = {
    "Name"                  = lookup(var.subnets[count.index],"name")
    "SubnetType"            = lookup(var.subnets[count.index],"subnet_type")
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "aws_ssm_parameter" "private" {
  count                     = length(var.subnets)
  name                      = "/network/${var.vpc_name}/${lookup(var.subnets[count.index],"subnet_type")}/subnet${count.index+1}"
  value                     = element(aws_subnet.private_subnets.*.id,count.index)
  type                      = "String"
}
resource "aws_ssm_parameter" "subnet_ids" {
  name                      = "/network/${var.vpc_name}/${lookup(var.subnets[0],"subnet_type")}_subnets"
  value                     = join(",",toset(aws_subnet.private_subnets.*.id))
  type                      = "String"
}
resource "aws_ssm_parameter" "cidr_blocks" {
  name                      = "/network/${var.vpc_name}/${lookup(var.subnets[0],"subnet_type")}_cidr_blocks"
  value                     = join(",",toset(aws_subnet.private_subnets.*.cidr_block))
  type                      = "String"
}
resource "aws_eip" "elastic_ip" {
  count                     = var.single_nat_gateway ? 1 : (var.multiple_nat_gateway ? length(var.eip_allocation_subnets) : 0)
  domain                    = "vpc"
}
resource "aws_nat_gateway" "nat_gateway" {
  count                     = var.single_nat_gateway ? 1 : (var.multiple_nat_gateway ? length(var.eip_allocation_subnets) : 0)
  allocation_id             = aws_eip.elastic_ip.*.id[count.index]
  subnet_id                 = var.eip_allocation_subnets[count.index]
  tags                      = {"Name" = format("%s-ngw-%s",var.Environment,count.index+1) }
}

resource "aws_route_table" "private_subnet_route_table" {
  count                     = length(var.subnets)
  vpc_id                    = var.vpc_id
  route  {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = var.single_nat_gateway ? local.nat_gateway_ids[0]:  local.nat_gateway_ids[count.index]
  }
  lifecycle {
    ignore_changes            = [route]
  }
  tags                      = {"Name" = "${var.vpc_name}-${lookup(var.subnets[count.index],"subnet_type" )}${count.index}-route_table"}
}
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id                    = var.vpc_id
  service_name              = "com.amazonaws.${local.region}.s3"
  tags                      = {"Name" = "${var.vpc_name}-s3-gateway-endpoint"}
}
resource "aws_vpc_endpoint_route_table_association" "s3_route_table_association" {
  count                     = length(var.subnets)
  route_table_id            = element(aws_route_table.private_subnet_route_table.*.id,count.index )
  vpc_endpoint_id           = aws_vpc_endpoint.s3_gateway_endpoint.id
}
resource "aws_vpc_endpoint" "dynamodb_gateway_endpoint" {
  vpc_id                    = var.vpc_id
  service_name              = "com.amazonaws.${local.region}.dynamodb"
    tags                      = {"Name" = "${var.vpc_name}-dynamodb-gateway-endpoint"}
}
resource "aws_vpc_endpoint_route_table_association" "dynamodb_route_table_association" {
  count                     = length(var.subnets)
  route_table_id            = element(aws_route_table.private_subnet_route_table.*.id,count.index )
  vpc_endpoint_id           = aws_vpc_endpoint.dynamodb_gateway_endpoint.id
}
resource "aws_route_table_association" "route_table_association" {
  count                     = length(var.subnets)
  subnet_id                 = element(aws_subnet.private_subnets.*.id,count.index)
  route_table_id            = element(aws_route_table.private_subnet_route_table.*.id,count.index )
}
resource "aws_network_acl" "this" {
  vpc_id            = var.vpc_id
  tags              = { "Name" = "${var.vpc_name}-private-nacl" }
}
resource "aws_network_acl_association" "private_nacl_association" {
  count             = length(var.subnets)
  subnet_id         = element(aws_subnet.private_subnets.*.id,count.index)
  network_acl_id    = aws_network_acl.this.id
}
resource "aws_network_acl_rule" "private_subnet_rules" {
  network_acl_id    = aws_network_acl.this.id
  for_each = var.nacl_rules
  rule_number       = lookup(each.value,"rule_number",100)
  rule_action       = lookup(each.value,"action","")
  protocol          = lookup(each.value,"protocol","-1")
  egress            = lookup(each.value,"egress", false)
  from_port         = lookup(each.value,"from_port")
  to_port           = lookup(each.value,"to_port")
  cidr_block        = lookup(each.value,"cidr_block","")
}

resource "aws_route" "accepted" {
  count = length(var.static_route_table_associations)
  route_table_id = lookup(var.static_route_table_associations[count.index],"route_table_id" )
  destination_cidr_block = lookup(var.static_route_table_associations[count.index],"destination_cidr_block")
  vpc_peering_connection_id = lookup(var.static_route_table_associations[count.index], "vpc_peering_connection_id")
}
