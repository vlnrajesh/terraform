# security_group

This directory contains Terraform code for managing AWS Security Groups. The primary resources created are `aws_security_group` and associated rules.

## Overview

### .tflint.hcl

- Configures TFLint, a Terraform linter, for the `security_group` module.
- Enables the AWS plugin for TFLint (`github.com/terraform-linters/tflint-ruleset-aws`).
- Allows TFLint to check this module as a whole (`module = true`).
- Enables the AWS plugin (`enabled = true`) and specifies its version.

### main.tf 

- Creates an AWS security group using the `aws_security_group` resource.
- Parameters such as `name`, `description`, `vpc_id`, and `tags` are provided through variables (var).
- The security group's name and description are based on the input variables.
- It's associated with a specific VPC (`vpc_id`).
- Tags are applied for identification and organization.

- Defines two security group rules:
1. Default Egress Rule:
- Allows outbound access to the internet (`"0.0.0.0/0"`).
- Protocol is set to -1 to allow all protocols.
- This rule facilitates internet-bound traffic from resources within the security group.
2. Self Traffic Rule:
- Allows inbound traffic from the security group itself.
- This can be useful for internal communication between resources within the same security group.
- The rule allows traffic on all ports (`from_port`, `to_port`, and protocol are set to 0 and -1).

## Outputs

- **id** : The ID of the created security group.
- **name** : The name of the created security group. 