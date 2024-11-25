# vpc

This directory contains Terraform code for creating an Amazon Virtual Private Cloud (VPC) on AWS. The VPC setup includes configurations for VPC, Internet Gateway, DHCP options, Route 53 private hosted zone, IAM roles, CloudWatch Log Group, and Flow Logs.

## Overview

- Creates an AWS VPC (`aws_vpc`) with the specified CIDR block, DNS settings, and tags.
- Creates an internet gateway (`aws_internet_gateway`) and associates it with the VPC.
- Creates DHCP options (`aws_vpc_dhcp_options`) for the VPC with the specified domain name and domain name servers.
- Associates the VPC with the created DHCP options.
- Creates a private Route53 DNS zone (aws_route53_zone) for the VPC.
- Creates an IAM policy document allowing the VPC Flow Logs service to assume a role.
- Creates an IAM role (`aws_iam_role`) for VPC Flow Logs with the assumed role policy.
- Creates an IAM policy document (aws_iam_policy_document) specifying actions related to CloudWatch logs.
- Creates an IAM policy (`iam_policy`) for VPC Flow Logs using the policy document.
- Conditionally, Attaches the IAM policy (`aws_iam_role_policy_attachment`) to the IAM role.
- Creates a CloudWatch log group (`aws_cloudwatch_log_group`) for VPC flow logs with specified retention settings.
- Creates VPC flow logs (`aws_flow_log`) for the specified VPC, associating them with the CloudWatch log group and IAM role.

## Outputs

- Outputs providing information about the created VPC, Internet Gateway, CIDR block, VPC name, and hosted zone ID.
- Saves relevant information to AWS Systems Manager (SSM) Parameter Store.