resource "aws_subnet" "public_subnets" {
  count             = length(var.subnets)
  vpc_id            = var.vpc_id
  cidr_block        = lookup(var.subnets[count.index],"cidr")
  availability_zone = lookup(var.subnets[count.index],"availability_zone")
  map_public_ip_on_launch = true
  tags              = merge(var.tags,
    {
    "Name"          = lookup(var.subnets[count.index],"name")
    "SubnetType"    = lookup(var.subnets[count.index],"subnet_type")
  })
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "aws_ssm_parameter" "subnets" {
  count                      = length(var.subnets)
  name                       = "/network/${var.vpc_name}/${lookup(var.subnets[count.index],"subnet_type")}/subnet${count.index+1}"
  value                      = element(aws_subnet.public_subnets.*.id,count.index)
  type                       = "String"
}
resource "aws_ssm_parameter" "subnet_ids" {
  name                      = "/network/${var.vpc_name}/${lookup(var.subnets[0],"subnet_type")}_subnets"
  value                     = join(",",toset(aws_subnet.public_subnets.*.id))
  type                      = "String"
}
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id            = var.vpc_id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = var.internet_gateway_id
  }
  tags              = merge(var.tags,{"Name" = "${var.vpc_name}-public-route_table"})
}
resource "aws_route_table_association" "public_route_table_association" {
  count             = length(var.subnets)
  subnet_id         = element(aws_subnet.public_subnets.*.id,count.index)
  route_table_id    = aws_route_table.public_subnet_route_table.id
}
resource "aws_network_acl" "this" {
  vpc_id            = var.vpc_id
  tags              = merge(var.tags,{ "Name" = "${var.vpc_name}-public-nacl" })
}
resource "aws_network_acl_association" "public_nacl_association" {
  count             = length(var.subnets)
  subnet_id         = element(aws_subnet.public_subnets.*.id,count.index)
  network_acl_id    = aws_network_acl.this.id
}
resource "aws_network_acl_rule" "public_subnet_rules" {
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
