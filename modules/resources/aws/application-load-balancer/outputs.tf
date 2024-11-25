output security_group_id {
  value = module.lb_security_group.id
}
output "arn" {
  value = aws_lb.application_load_balancer.arn
}

