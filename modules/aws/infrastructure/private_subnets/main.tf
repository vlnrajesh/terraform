resource "aws_subnet" "private_subnets" {
  count                     = length(var.PRIVATE_NETWORKS)
  vpc_id                    = var.VPC_ID
  cidr_block                = lookup(var.PRIVATE_NETWORKS[count.index],"cidr")
  availability_zone         = lookup(var.PRIVATE_NETWORKS[count.index],"availability_zone")
  map_public_ip_on_launch   = false
  tags                      = merge(var.TAGS,
                                {"Name"=lookup(var.PRIVATE_NETWORKS[count.index],"name")}
                              )
}
resource "aws_eip"    "elastic_ips" {
  count                     = length(var.PRIVATE_NETWORKS)
  vpc                       = true
  tags                      = merge(var.TAGS,
                                {"Name"=lookup(var.PRIVATE_NETWORKS[count.index],"name")}
                              )
}
resource "aws_nat_gateway" "nat_gateway" {
  count                     = length(var.PRIVATE_NETWORKS)
  allocation_id             = aws_eip.elastic_ips.*.id[count.index]
  subnet_id                 = var.PUBLIC_SUBNET_IDS[count.index]
  tags                      = merge(var.TAGS,
                                {"Name"=lookup(var.PRIVATE_NETWORKS[count.index],"name")}
                              )
}
resource "aws_route_table"  "private_subnet_route_table" {
  count                     = length(var.PRIVATE_NETWORKS)
  vpc_id                    = var.VPC_ID
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.nat_gateway[count.index].id
  }
}
resource "aws_route_table_association" "route_table_association" {
  count                     = length(var.PRIVATE_NETWORKS)
  subnet_id                 = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id            = element(aws_route_table.private_subnet_route_table.*.id,count.index)
}
