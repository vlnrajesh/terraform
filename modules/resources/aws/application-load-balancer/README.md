# Application load balancer

This Terraform module defines an AWS Application Load Balancer (ALB) along with associated configurations such as security groups and listeners.

## Overview

- The module uses the `lb_security_group` module from the `../../aws/security_group source`.
- Creates a security group for the load balancer, allowing inbound traffic on ports 80 and 443 from any IP address.
- Defines two security group rules (`aws_security_group_rule` resources) allowing inbound traffic on ports 80 (HTTP) and 443 (HTTPS) from any IP address.
- These rules are associated with the security group created by the `lb_security_group module`.
- Defines an `aws_lb resource` for an Application Load Balancer.
- Specifies the name, type (application), associated security groups, subnets, and internal/external accessibility based on provided variables.
- Tags the load balancer with a name based on the variable `var.load_balancer_name`.
- Optionally, creates an HTTP listener (`aws_lb_listener`) on port 80.
- Redirects HTTP traffic to HTTPS (port 443) using a 301 redirect.
- Optionally, creates an HTTPS listener (`aws_alb_listener`) on port 443.
- Uses a specified SSL policy and, if provided, associates an ACM certificate.
- Allows customization of the default action for the listener based on the provided variables.
- Creates AWS Systems Manager (SSM) parameters for the ALB's ARN and security group ID.
- Useful for parameterizing and referencing these values in other parts of the infrastructure.

## Outputs

- **security_group_id** : Security group ID associated with the load balancer
- **arn** :	ARN of the created application load balancer