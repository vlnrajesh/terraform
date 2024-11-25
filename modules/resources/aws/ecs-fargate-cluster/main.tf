locals {
  execution_role_name = "${var.cluster_name}_ecs_execution_role"
}
resource "aws_iam_role" "ecs_execution_role" {
  name                  = local.execution_role_name
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
  tags                = {"Name"     = local.execution_role_name}
}
resource "aws_iam_policy" "ecs_task_execution_iam_policy" {
  name                  = "${var.cluster_name}_execution_policy"
  policy                = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Sid: "ECRAccess",
        Action: [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect: "Allow",
        Resource: "*"
      },
      {
        Sid:  "CloudWatchlog",
        Action: [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        Effect: "Allow",
        Resource: [
          "${aws_cloudwatch_log_group.ecs_cluster_log_group.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role            = aws_iam_role.ecs_execution_role.name
  policy_arn      = aws_iam_policy.ecs_task_execution_iam_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name                  = var.cluster_name
  retention_in_days     = var.log_retention_in_days
  tags                  = {"Name" = var.cluster_name}
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name                  = var.cluster_name
  setting {
    name                = "containerInsights"
    value               = var.container_insights
  }
  tags                  = {"Name" = var.cluster_name}
}
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity" {
  cluster_name          = aws_ecs_cluster.ecs_cluster.name
  capacity_providers    = [ "FARGATE_SPOT","FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider   = var.capacity_provider
  }
}
