locals{
  sonarqube_security_group_name = "${var.service_name}-sg"
}

module "security_group" {
  source                       = "../../resources/aws/security_group"
  security_group_name          = local.sonarqube_security_group_name
  vpc_id                       = var.vpc_id
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id               = module.efs.id
  posix_user {
    gid       = 1000
    uid       = 1000
  }
  root_directory {
    path      = "/"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
  tags                         = {"Name" = "${var.service_name}-acces_point"}
}
resource "aws_security_group_rule" "efs_ingress_sq" {
  security_group_id             = var.efs_security_group_id
  source_security_group_id      = module.security_group.id
  description                   = "Access EFS from ${local.sonarqube_security_group_name}"
  protocol                      = "tcp"
  from_port                     = var.efs_port
  to_port                       = var.efs_port
  type                          = "ingress"
}

resource "aws_security_group_rule" "sq_ingress_alb" {
  security_group_id             = module.security_group.id
  source_security_group_id      = var.load_balancer_security_group_id
  description                   = "Allow sonarqube from load balancer"
  protocol                      = "tcp"
  from_port                     = var.sonarqube_app_port
  to_port                       = var.sonarqube_app_port
  type                          = "ingress"
}
resource "aws_security_group_rule" "rds_ingress_sq" {
  security_group_id             = var.rds_security_group_id
  source_security_group_id      = module.security_group.id
  description                   = "Access DB from ${local.sonarqube_security_group_name}"
  protocol                      = "tcp"
  from_port                     = var.rds_db_port
  to_port                       = var.rds_db_port
  type                          = "ingress"
}

#
resource "aws_lb_target_group" "this" {
  name                          = var.service_name
  port                          = var.sonarqube_app_port
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  target_type                   = "ip"
  health_check {
    enabled       = true
    path          = "/"
  }
  lifecycle {
    create_before_destroy       =  true
  }
  tags                          = {"Name" : var.service_name}
}
module "sq-fargate-service" {
  source    = "../../resources/aws/ecs-fargate-service"
  service_name                 = var.service_name
  cluster_name                 = var.cluster_name
  cloudwatch_log_group_name    = var.cloudwatch_log_group_name
  subnets                      = var.subnets
  vpc_id                       = var.vpc_id
  desired_count                = var.desired_service_count
  security_group_id            = module.security_group.id
  container_definitions        = templatefile("${path.module}/container_definitions/sq_server.tpl",{
    container_name    = var.service_name
    container_image   = var.container_image
    cpu               = var.cpu
    memory            = var.memory
    sq_db_username    = var.rds_username
    sq_db_url         = "jdbc:postgresql://${var.connection_string}/${var.rds_initial_db_name}"
    sq_app_port       = var.sonarqube_app_port
    log_group         = var.cloudwatch_log_group_name
    region            = local.region
    plugins_home      = var.plugins_home
    sq_password_arn   = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/rds/${var.identifier_name}/password"
    })
    load_balancer = {
      target_group_arn  = aws_lb_target_group.this.arn
      container_name    = var.service_name
      container_port    = var.sonarqube_app_port
    }
    volume = {
      name      = "efs-volume"
      efs_volume_configuration = {
        file_system_id     = var.efs_id
        transit_encryption = "ENABLED"
        authorization_config = {
        access_point_id   = aws_efs_access_point.efs_access_point.id
        iam = "ENABLED"
      }
    }
  }
  ecs_execution_role_arn = var.ecs_execution_role_arn
}

resource "aws_iam_policy" "sq_iam_policy" {
 name                = "${var.service_name}_iam_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Sid: "SSMOperations"
        Action: [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Effect: "Allow",
        Resource: [
          "arn:aws:ssm:${local.region}:${local.account_id}:parameter/rds/${var.identifier_name}/*"
          ]
      },
      {
        Sid: "KMSDecryption"
        Action: [
          "kms:Decrypt"
        ],
        Effect: "Allow",
        Resource: [
          "arn:aws:kms:${local.region}:${local.account_id}:alias/aws/ssm"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role            =var.ecs_execution_role_name
  policy_arn      = aws_iam_policy.sq_iam_policy.arn
}
#
#resource "aws_service_discovery_private_dns_namespace" "master" {
#  name                = var.service_name
#  description         = "${var.service_name} discovery managed zone"
#  vpc                 = var.vpc_id
#}
#resource "aws_service_discovery_service" "master" {
#  name                = "master"
#  dns_config {
#    namespace_id      = aws_service_discovery_private_dns_namespace.master.id
#    routing_policy    = "MULTIVALUE"
#    dns_records       {
#      ttl = 10
#      type = "A"
#    }
#    dns_records       {
#      ttl = 10
#      type = "SRV"
#    }
#  }
#  health_check_custom_config {
#    failure_threshold = 5
#  }
#}