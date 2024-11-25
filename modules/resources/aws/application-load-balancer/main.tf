module lb_security_group {
  security_group_name = "${var.load_balancer_name}-sg"
  source              = "../../aws/security_group"
  vpc_id              = var.vpc_id
}
resource "aws_security_group_rule" "allow_https" {
  security_group_id = module.lb_security_group.id
  description       = "Allow HTTPS Inbound traffic from internet"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}
resource "aws_security_group_rule" "allow_http" {
  security_group_id = module.lb_security_group.id
  description       = "Allow HTTP Inbound traffic from internet"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}
resource "aws_lb" "application_load_balancer" {
  name                  = var.load_balancer_name
  load_balancer_type    = "application"
  security_groups       = [module.lb_security_group.id]
  subnets               = var.subnets
  internal              = var.internal_load_balancer
  tags                  = { "Name" : var.load_balancer_name }
}
resource "aws_lb_listener" "listener_http" {
  count                       = var.create_http_listener ? 1 : 0
  load_balancer_arn           = aws_lb.application_load_balancer.arn
  port                        = 80
  protocol                    = "HTTP"
  default_action {
    type  = "redirect"
    redirect {
      port        = 433
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_alb_listener" "listener_https" {
  count                       = var.create_https_listener ? 1 : 0
  load_balancer_arn           = aws_lb.application_load_balancer.arn
  port                        = 443
  protocol                    = "HTTPS"
  ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn             = var.create_https_listener? var.acm_certificate_arn: null
  dynamic "default_action" {
    for_each = var.default_action
    content {
      type = var.default_action[0].type
      target_group_arn = var.default_action[0].target_group_arn

    }
  }
}
resource "aws_ssm_parameter" "arn" {
  name = "/alb/${var.load_balancer_name}/arn"
  type = "String"
  value = aws_lb.application_load_balancer.arn
  tags = {"Name": var.load_balancer_name}
}
resource "aws_ssm_parameter" "security_group_id" {
  name = "/alb/${var.load_balancer_name}/security_group_id"
  type = "String"
  value = module.lb_security_group.id
  tags = {"Name": "${var.load_balancer_name}-sg"}
}