locals{
  db_subnet_group_name = var.create_subnet_group ? module.db_subnet_group.id : var.db_subnet_group_name
  parameter_group_name = var.create_parameter_group ? module.db_parameter_group.id : var.parameter_group_name
  option_group_name = var.create_option_group ? module.option_group.id : var.option_group_name
}
module "db_security_group" {
  source = "../../aws/security_group"
  security_group_name = "${var.identifier_name}-db-sg"
  vpc_id              = var.vpc_id
}

module "db_subnet_group" {
  source = "./modules/subnet_group"
  create                        = var.create_subnet_group
  db_identifier_name            = var.identifier_name
  subnet_ids                    = var.subnets
}
module "db_parameter_group" {
  source = "./modules/parameter_group"
  create    = var.create_parameter_group
  db_identifier_name           = var.identifier_name
  family                       = var.family
}
module "option_group" {
  source = "./modules/option_group"
  create = var.create_option_group
  db_identifier_name           = var.identifier_name
  engine_name                  = var.engine_name
  major_engine_version         = var.engine_version
}
resource "random_password" "master_password" {
  length                      = 16
  special                     = true
  override_special            = "_!%^"
}

resource "aws_ssm_parameter" "rds_username" {
  name          = "/rds/${var.identifier_name}/username"
  type          = "String"
  value         = var.db_username
  tags          = {"Name": "${var.identifier_name}-rds-username"}
}
resource "aws_ssm_parameter" "rds_endpoint" {
  name          = "/rds/${var.identifier_name}/endpoint"
  type          = "String"
  value         = aws_db_instance.rds.endpoint
  tags          = {"Name": "${var.identifier_name}-rds-endpoint"}
}
resource "aws_ssm_parameter" "rds_port" {
  name          = "/rds/${var.identifier_name}/dbport"
  type          = "String"
  value         = aws_db_instance.rds.port
  tags          = {"Name": "${var.identifier_name}-rds-port"}
}

resource "aws_ssm_parameter" "rds_credentials" {
  name = "/rds/${var.identifier_name}/password"
  value = random_password.master_password.result
  type = "SecureString"
  tags          = {"Name": "${var.identifier_name}-rds-password"}
}

resource "aws_db_instance" "rds" {
  identifier                  = var.identifier_name
  instance_class              = var.instance_class
  username                    = var.db_username
  password                    = random_password.master_password.result
  engine                      = var.engine_name
  engine_version              = var.engine_version
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.storage_encrypted
  db_subnet_group_name        = local.db_subnet_group_name
  parameter_group_name        = module.db_parameter_group.id
  option_group_name           = module.option_group.id
  vpc_security_group_ids      = [module.db_security_group.id]
  port                        = lookup(var.port,var.engine_name)
  multi_az                    = var.multi_az
  db_name                     = try(var.initial_db_name,null)
  backup_retention_period     = var.backup_retention_period
  copy_tags_to_snapshot       = true
  skip_final_snapshot         = true
  publicly_accessible         = false
  apply_immediately           = true
  deletion_protection         = true
  tags                        = {"Name": var.identifier_name}
}
resource "aws_secretsmanager_secret" this {
  name          = "${var.identifier_name}_credentials"
  description   = "Secrets created for ${var.identifier_name}"
  tags          = {"Name": var.identifier_name}
}
resource "aws_secretsmanager_secret_version" "secret_version" {
  depends_on = [aws_secretsmanager_secret.this]
  secret_id = aws_secretsmanager_secret.this.name
  secret_string = jsonencode({
        "engine"        : var.engine_name,
        "host"          : aws_db_instance.rds.endpoint,
        "username"      : var.db_username,
        "password"      : random_password.master_password.result,
        "dbname"        : aws_db_instance.rds.db_name,
        "port"          : aws_db_instance.rds.port
    })
}
module "rds-secret-rotation" {
  source = "./modules/rds-secret-rotation"
  identifier_name             = var.identifier_name
  lambda_function_name        = "postgres_single_user_rotator"
  security_group_id           = module.db_security_group.id
  subnets                     = var.subnets
  secret_id                   = aws_secretsmanager_secret.this.id
}