locals {
  service_prefix="${var.cluster_name}_${var.service_name}"
}
resource "aws_iam_role" "ecs_task_role" {
  name                  = "${local.service_prefix}-task_role"
  description           = "Allow ECS tasks to access aws resources"
  assume_role_policy    = jsonencode({
    "Version"     : "2012-10-17"
    "Statement"   : [
      {
        Sid       : "TaskAccess",
        Effect    :  "Allow",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
        Action    : "sts:AssumeRole"
      }
    ]
  })
  tags                = {"Name" = "${local.service_prefix}-task-role"}
}
resource "aws_iam_policy" "service_task_execution_policy" {
  name                  = "${local.service_prefix}_task_policy"
  policy                = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Sid: "SSMAccess"
        Action: [
          "ssm:*",
        ],
        Effect: "Allow",
        Resource: "*"
      },
      {
        Sid: "SSMMessages"
        Action: [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Effect: "Allow",
        Resource: "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role            = aws_iam_role.ecs_task_role.name
  policy_arn      = aws_iam_policy.service_task_execution_policy.arn
}
resource "aws_ecs_task_definition" "service_task" {
  family                    = "${var.cluster_name}-${var.service_name}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = var.cpu
  memory                    = var.memory
  execution_role_arn        = var.ecs_execution_role_arn
  task_role_arn             = aws_iam_role.ecs_task_role.arn
  container_definitions     = var.container_definitions
  dynamic  "volume" {
    for_each = var.volume
    content {
      name = try(var.volume.name,null)
      dynamic "efs_volume_configuration" {
        for_each = try([volume.value.efs_volume_configuration],[])
        content {
          dynamic "authorization_config" {
            for_each = try([efs_volume_configuration.value.authorization_config], [])
            content {
              access_point_id = lookup(var.volume.efs_file_system_id.authorization_config.access_point_id, null)
              iam             = lookup(var.volume.efs_file_system_id.authorization_config.iam, null)
            }
          }
          file_system_id          = lookup(var.volume.efs_file_system_id.file_system_id, null)
          root_directory          = lookup(var.volume.efs_file_system_id.root_directory, null)
          transit_encryption      = lookup(var.volume.efs_file_system_id.transit_encryption, null)
          transit_encryption_port = lookup(var.volume.efs_file_system_id.transit_encryption_port, null)
        }
      }
    }
  }
  tags                      = {"Name" = "${local.service_prefix}-task_definition"}
}
resource "aws_ecs_service" "service" {
  name                = var.service_name
  cluster             = var.cluster_name
  desired_count       = var.desired_count
  propagate_tags      = "TASK_DEFINITION"
  enable_execute_command = true
  task_definition     = aws_ecs_task_definition.service_task.arn
  network_configuration {
    subnets           = var.subnets
    security_groups   = [var.security_group_id]
    assign_public_ip  = var.assign_public_ip
  }
  capacity_provider_strategy {
    capacity_provider = var.fargate_spot ? "FARGATE_SPOT" : "FARGATE"
    weight            = 1
    base              = 1
  }
  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn  = try(var.load_balancer.target_group_arn,null)
      container_name =  try(var.load_balancer.container_name,null)
      container_port = try(var.load_balancer.container_port,null)
    }
  }
  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn      = var.service_registries[0].registry_arn
      port              = var.service_registries[0].port
    }
  }
  tags                = {"Name" : var.service_name}
}
module "scale_configuration" {
  source = "./auto-scaling"
  count               = var.scale_service ? 1 : 0
  ecs_cluster_name    = var.cluster_name
  ecs_service_name    = aws_ecs_service.service.name
  metric_type         = var.auto_scale_configuration.metric_type
  permissible_value   = var.auto_scale_configuration.permissible_value
  min_capacity        = var.auto_scale_configuration.minimum_capacity
  max_capacity        = var.auto_scale_configuration.maximum_capacity
}