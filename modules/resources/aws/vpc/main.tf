locals {
  domain_name = split(".", var.dns_domain_name)[0]
}
resource "aws_vpc" "this" {
  cidr_block                  = var.cidr_block
  enable_dns_hostnames        = var.enable_dns_hostnames
  enable_dns_support          = var.enable_dns_support
  tags                        = {Name = var.vpc_name}

}
resource "aws_internet_gateway" "vpc_internet_gateway" {
  depends_on                  = [aws_vpc.this]
  vpc_id                      = aws_vpc.this.id
  tags                        = {Name = "${var.vpc_name}_interget_gateway"}
}
resource "aws_vpc_dhcp_options" "dhcp_options" {
  depends_on                  =  [aws_vpc.this]
  domain_name                 = var.dns_domain_name
  domain_name_servers         = ["AmazonProvidedDNS"]
  tags                        = { Name="${var.vpc_name}_dhcp_options"}
}
resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  depends_on                  = [
    aws_vpc.this,
    aws_vpc_dhcp_options.dhcp_options
  ]
  dhcp_options_id             = aws_vpc_dhcp_options.dhcp_options.id
  vpc_id                      = aws_vpc.this.id
}
resource "aws_route53_zone" "private" {
  name                       = var.dns_domain_name
  vpc {
    vpc_id = aws_vpc.this.id
  }
  lifecycle {
    ignore_changes           = [vpc]
  }
  tags                       = {"Name": var.vpc_name}
}
resource "aws_route53_zone_association" "secondary" {
  count                       = length(var.additional_vpc_ids)
  zone_id                     = aws_route53_zone.private.id
  vpc_id                      = var.additional_vpc_ids[count.index]
}
data "aws_iam_policy_document" "role" {
  count                       = var.enable_vpc_flow_logs == true ? 1 : 0
  statement {
    actions                   = ["sts:AssumeRole"]
    principals {
      identifiers             = ["vpc-flow-logs.amazonaws.com"]
      type                    = "Service"
    }
  }
}

resource "aws_iam_role" "vpc_flow_log_iam_assume_role" {
  count                       = var.enable_vpc_flow_logs == true ? 1 : 0
  name                        = "${var.vpc_name}-vpc-flow-iam-role"
  assume_role_policy          = data.aws_iam_policy_document.role[count.index].json
}

data "aws_iam_policy_document" "policy_document" {
  count                       = var.enable_vpc_flow_logs == true ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "*",
    ]
  }
}
resource "aws_iam_policy" "vpc_flow_log_iam_policy_document" {
  count                       = var.enable_vpc_flow_logs == true ? 1 : 0
  name                        = "${var.vpc_name}-vpc_flow_log_policy"
  description                 = "VPC flow log policy for ${var.vpc_name}"
  policy                      = data.aws_iam_policy_document.policy_document[count.index].json
}
resource "aws_iam_role_policy_attachment" "vpc_flow_log_iam_role" {
  count                       = var.enable_vpc_flow_logs == true ? 1 : 0
  role                        = aws_iam_role.vpc_flow_log_iam_assume_role[count.index].name
  policy_arn                  = aws_iam_policy.vpc_flow_log_iam_policy_document[count.index].arn
}
data "aws_ssm_parameter" "expiration_days" {
  name                       = "/${var.Environment}/expiration_in_days"
}
resource "aws_cloudwatch_log_group" "vpc_flowlog_group" {
  count                      = var.enable_vpc_flow_logs == true ? 1 :0
  name                       = "${var.vpc_name}_vpc_flowlog_group"
  retention_in_days          = data.aws_ssm_parameter.expiration_days.value
  lifecycle {
    create_before_destroy   = true
    prevent_destroy         = false
  }
  tags                       = {Name="${var.vpc_name}_vpc_flowlog_group"}
}
resource "aws_flow_log" "vpc_flow_log" {
  count                      = var.enable_vpc_flow_logs == true ? 1 : 0

  log_destination            = aws_cloudwatch_log_group.vpc_flowlog_group[count.index].arn
  iam_role_arn               = aws_iam_role.vpc_flow_log_iam_assume_role[count.index].arn
  vpc_id                     = aws_vpc.this.id
  traffic_type               = var.traffic_type
  tags                       = {Name="${var.vpc_name}_vpc_flowlog"}
}
