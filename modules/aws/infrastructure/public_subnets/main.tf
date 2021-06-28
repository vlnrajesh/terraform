resource "aws_subnet" "public_subnets" {
  count                     = length(var.PUBLIC_SUBNETS)
  vpc_id                    = var.VPC_ID
  cidr_block                = lookup(var.PUBLIC_SUBNETS[count.index],"cidr")
  availability_zone         = lookup(var.PUBLIC_SUBNETS[count.index],"availability_zone")
  map_public_ip_on_launch   = true
  tags                      = merge(var.TAGS,
                                {"Name"=lookup(var.PUBLIC_SUBNETS[count.index],"name")}
                              )
}


resource "aws_route_table" "public_subnet_route_table" {
  vpc_id                    = var.VPC_ID
  route                     {
      cidr_block            = "0.0.0.0/0"
      gateway_id            = var.INTERNET_GATEWAY_ID
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count                     = length(var.PUBLIC_SUBNETS)
  subnet_id                 = element(aws_subnet.public_subnets.*.id,count.index)
  route_table_id            = element(aws_route_table.public_subnet_route_table.*.id,count.index )
}