locals {
  name = "${var.db_identifier_name}-db-parametergroup"
}
resource "aws_db_parameter_group" "this" {
  count       = var.create? 1 : 0
  name        = local.name
  description = "${local.name}-parameter group"
  family      = var.family
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name        = parameter.value.name
      value       = parameter.value.value
      apply_method = lookup(parameter.value,"apply_method",null)
    }
  }
  tags        = {"Name" = local.name}
  lifecycle {
    create_before_destroy = true
  }
}