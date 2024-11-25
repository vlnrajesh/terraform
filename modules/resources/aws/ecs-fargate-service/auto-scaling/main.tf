locals {
  resource_id           = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  policy_name           = "${var.ecs_cluster_name}_${var.ecs_service_name}"
}
resource "aws_appautoscaling_target" ecs_target {
  min_capacity          = var.min_capacity
  max_capacity          = var.max_capacity
  resource_id           = local.resource_id
  scalable_dimension    = "ecs:service:DesiredCount"
  service_namespace     = "ecs"
  tags                  = {"Name": local.resource_id}
}
resource "aws_appautoscaling_policy" "cpu_target" {
  count                 = upper(var.metric_type) == "CPU" ? 1 : 0
  name                  = "${local.policy_name}-cpu"
  policy_type           = var.policy_type
  resource_id           = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension    = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace     = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value    = var.permissible_value
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
resource "aws_appautoscaling_policy" "memory_target" {
  count                 = upper(var.metric_type) == "MEMORY" ? 1 : 0
  name                  = "${local.policy_name}-memory"
  policy_type           = var.policy_type
  resource_id           = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension    = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace     = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value  = var.permissible_value
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}