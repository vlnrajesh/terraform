resource "aws_vpc" "vpc" {
  cidr_block                = var.CIDR
  enable_dns_hostnames      = var.ENABLE_DNS_HOSTNAMES
  enable_dns_support        = var.ENABLE_DNS_SUPPORT
  tags                      = var.TAGS
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  depends_on                = [aws_vpc.vpc]
  vpc_id                    = aws_vpc.vpc.id
  tags                      = var.TAGS
}
resource "aws_vpc_dhcp_options" "dhcp_options" {
  depends_on                = [aws_vpc.vpc]
  domain_name               = "${var.AWS_REGION}.compute.local"
  domain_name_servers       = ["AmazonProvidedDNS"]
  tags                      = var.TAGS
}
resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  depends_on = [
    aws_vpc.vpc,
    aws_vpc_dhcp_options.dhcp_options
  ]
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
  vpc_id = aws_vpc.vpc.id
}