# private_subnets

This Terraform module creates private subnets in an Amazon Web Services (AWS) Virtual Private Cloud (VPC) with optional features like Network ACLs, NAT Gateways, and VPC Endpoints for services like S3 and DynamoDB.

## Overview

- Configures TFLint, a Terraform linter, with settings for AWS-specific rules.
- Creates private subnets (`aws_subnet.private_subnets`) within the specified VPC.
- Associates relevant attributes such as CIDR blocks, availability zones, and tags to the subnets.
- Excludes public IP assignment to instances launched in these subnets (`map_public_ip_on_launch = false`).
- Creates AWS Systems Manager (SSM) parameters (`aws_ssm_parameter`) to store information about the private subnets.
- Parameters include subnet IDs, CIDR blocks, and specific details for each subnet.
- Creates Elastic IPs (`aws_eip.elastic_ip`) for NAT gateways if specified.
- Creates NAT gateways (`aws_nat_gateway.nat_gateway`) associated with the Elastic IPs.
- Associates each NAT gateway with a specific private subnet.
- Creates route tables (`aws_route_table.private_subnet_route_table`) for each private subnet.
- Configures a default route in each route table, pointing to the respective NAT gateway for internet access.
- Creates VPC endpoints for S3 and DynamoDB (`aws_vpc_endpoint.s3_gateway_endpoint` and `aws_vpc_endpoint.dynamodb_gateway_endpoint`).
- Associates the VPC endpoints with the private subnets using `aws_vpc_endpoint_route_table_association`.
- Creates a network ACL (`aws_network_acl.this`) and associates it with the VPC.
- Configures network ACL rules (`aws_network_acl_rule.private_subnet_rules`) for controlling inbound and outbound traffic.
- Associates the network ACL with the private subnets.
- Creates static routes (`aws_route.accepted`) in specified route tables, useful for VPC peering connections.

## Outputs

- **subnet_ids** : Outputs the IDs of the created private subnets.
- **cidr_block** : Outputs the CIDR blocks of the private subnets.
- **nat_gateway_ids** : Outputs the IDs of the NAT gateways created.