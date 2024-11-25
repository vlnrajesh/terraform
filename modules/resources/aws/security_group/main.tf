resource "aws_security_group" "security_group" {
  name                = var.security_group_name
  description         = var.description
  vpc_id              = var.vpc_id
  tags                = { "Name" : var.security_group_name, "ResourceName": "security_group@${local.resource_path}"}
}
resource "aws_security_group_rule" "default_egress_rule" {
  security_group_id   = aws_security_group.security_group.id
  description         = "Outbound access to internet for ${var.security_group_name}"
  type                = "egress"
  cidr_blocks         = ["0.0.0.0/0"]
  protocol            = -1
  from_port           = 0
  to_port             = 0
}
resource "aws_security_group_rule" "sq_app_self_traffic" {
  security_group_id   = aws_security_group.security_group.id
  description         = "Self traffic"
  type                = "ingress"
  from_port           = 0
  to_port             = 0
  protocol            = -1
  self                = true
}
