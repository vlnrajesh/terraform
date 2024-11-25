# public subnets

This directory contains Terraform code for managing public subnets within an AWS infrastructure.

## Overview

- Configures TFLint, a Terraform linter, with settings for AWS-specific rules.
- Creates public subnets (`aws_subnet.public_subnets`) within the specified VPC.
- Associates relevant attributes such as CIDR blocks, availability zones, and tags to the subnets.
- Enables public IP assignment to instances launched in these subnets (`map_public_ip_on_launch = true`).
- Creates AWS Systems Manager (SSM) parameters (`aws_ssm_parameter`) to store information about the public subnets.
- Parameters include subnet IDs and specific details for each subnet.
- Creates a route table (`aws_route_table.public_subnet_route_table`) for public subnets.
- Configures a default route in the route table, pointing to the specified internet gateway for internet access.
- Associates each public subnet with the public route table (`aws_route_table_association.public_route_table_association`).
- Creates a network ACL (`aws_network_acl.this`) and associates it with the VPC.
- Configures network ACL rules (`aws_network_acl_rule.public_subnet_rules`) for controlling inbound and outbound traffic.
- Associates the network ACL with the public subnets.

## Outputs

- **subnet_ids** : Outputs the IDs of the created public subnets