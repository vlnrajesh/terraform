data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  lambda_input_path       = "${path.module}/functions/${var.lambda_function_name}"
  lambda_output_path      = "${path.module}/functions/${var.lambda_function_name}.zip"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  function_name           = "${var.identifier_name}-${var.lambda_function_name}"
}
data "archive_file" "deploy-package" {
  type                    = "zip"
  source_dir              = local.lambda_input_path
  output_path             = local.lambda_output_path
  excludes = [
    "__pycache__",
    "core/__pycache__",
    "tests"
  ]
}
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions             = ["sts:AssumeRole"]
    effect              = "Allow"
    principals {
      type              = "Service"
      identifiers       = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "this" {
  name                  = "${local.function_name}-lambda-execution-role"
  assume_role_policy    = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  tags                  = {"Name": "${local.function_name}-iam-role" }
}
resource "aws_iam_policy" "this" {
  name                 = "${local.function_name}_lambda_iam_policy"
  path                 = "/"
  description          = "IAM policy for Lambda function"
  policy               = jsonencode({
      Version     = "2012-10-17"
      Statement   = [
        {
          Sid         = "CloudwatchLogs"
          Effect      = "Allow",
          Resource    = "arn:aws:logs:${local.region}:${local.account_id}:*",
          Action      = [
            "logs:createLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          Sid         = "SecretsAccessManager"
          Effect      = "Allow",
          Resource    = "*",
          Action      = [
            "secretsmanager:CreateSecret",
            "secretsmanager:PutSecretValue",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DeleteSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetRandomPassword"
          ]
        }
      ]
  })
}
resource "aws_iam_role_policy_attachment" "policy_attach" {
  policy_arn          = aws_iam_policy.this.arn
  role                = aws_iam_role.this.name
}
resource "aws_iam_role_policy_attachment" "lambda-basic" {
  policy_arn          = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role                = aws_iam_role.this.name
}
resource "aws_iam_role_policy_attachment" "VPCAttachement" {
  role                = aws_iam_role.this.name
  policy_arn          = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_lambda_permission" "allow_secret_manager_call_lambda" {
  statement_id        = "AllowExecutionSecretManager"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.password_rotation.function_name
  principal           = "secretsmanager.amazonaws.com"
}
resource "aws_lambda_function" "password_rotation" {
  depends_on          = [aws_iam_role_policy_attachment.policy_attach]
  description         = "Lambda for rotation of RDS password"
  function_name       = local.function_name
  filename            = data.archive_file.deploy-package.output_path
  source_code_hash    = data.archive_file.deploy-package.output_base64sha256
  role                = aws_iam_role.this.arn
  handler             = "app.lambda_handler"
  runtime             = var.runtime
  environment {
    variables = {
    SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${local.region}.amazonaws.com"
    }
  }
  memory_size         =  var.memory_size
  timeout             = var.timeout
  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = var.subnets
  }
}
resource "aws_secretsmanager_secret_rotation" "password_rotation" {
  rotation_lambda_arn = aws_lambda_function.password_rotation.arn
  secret_id           =  var.secret_id
  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}