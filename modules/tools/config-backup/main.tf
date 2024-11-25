resource "aws_s3_bucket" "data_bucket" {
  bucket                  = "${var.s3_bucket_prefix}-${local.account_id}"
  tags                    = {"Name" = "${var.s3_bucket_prefix}-${local.account_id}", "ResourceName": "data_bucket@${local.resource_path}" }
}
resource "aws_s3_bucket_versioning" "versioning_devops-data-bucket" {
  bucket                  = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status                = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "protected_bucket_access" {
  bucket                  = aws_s3_bucket.data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
data "archive_file" "deploy-package" {
  type                    = "zip"
  source_dir              = local.lambda_src_path
  output_path             = local.lambda_dest_path
  excludes = [
    "__pycache__",
    "core/__pycache__",
    "tests"
  ]
}
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions               = ["sts:AssumeRole"]
    effect                = "Allow"
    principals {
      type                = "Service"
      identifiers         = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_role" {
  name                    = "${var.lambda_function_name}-${local.account_id}-lambda-execution-role"
  assume_role_policy      = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  tags                    = {"Name": "${var.lambda_function_name}-iam-role" }
}
resource "aws_iam_policy" "lambda_iam_role" {
  name                    = "${var.lambda_function_name}_${local.account_id}-lambda_iam_policy"
  path                    = "/"
  description             = "IAM policy for Lambda function"
  policy                  = jsonencode({
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
          Sid        = "S3Actions",
          Effect     = "Allow",
          Resource   = ["*"],
          Action     = [
            "s3:*"
          ]
        },
        {
          Sid       = "SSMOperations"
          Effect    = "Allow",
          Resource  = "*",
          Action    = [
            "ssm:*"
          ]
        }
      ]
  })
}
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role                    = aws_iam_role.lambda_role.name
  policy_arn              = aws_iam_policy.lambda_iam_role.arn
}
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role                  = aws_iam_role.lambda_role.name
    policy_arn            = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
module "security_group" {
  source                  = "../../resources/aws/security_group"
  security_group_name     = "${var.lambda_function_name}-lambda-sg"
  vpc_id                  = var.vpc_id
}
resource "aws_cloudwatch_log_group" "log_group" {
  name                    = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days       = 7
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
  tags                    = {"Name": var.lambda_function_name, "ResourceName": "log_group@${local.resource_path}"}
}
resource "aws_lambda_function" "config_backup" {
  depends_on              = [aws_iam_role_policy_attachment.policy_attach]
  filename                = data.archive_file.deploy-package.output_path
  source_code_hash        = data.archive_file.deploy-package.output_base64sha256
  description             = "Lambda for configuration file(s) backup"
  function_name           = var.lambda_function_name
  role                    = aws_iam_role.lambda_role.arn
  handler                 = "app.lambda_handler"
  runtime                 = var.runtime
  memory_size             = var.memory_size
  timeout                 = var.timeout
  vpc_config {
    security_group_ids    = [module.security_group.id]
    subnet_ids            = var.subnets
  }
  environment {
    variables = {
      S3_BUCKET_NAME      = aws_s3_bucket.data_bucket.id
    }
  }
  tags                    = {"Name": var.lambda_function_name, "ResourceName": "config_backup@${local.resource_path}"}
}
resource "aws_cloudwatch_event_rule" "ssm_change_rule" {
  name                    = "SSMParameterChangeRule"
  description             = "Trigger Lambda on SSM parameter change"
  event_pattern           = jsonencode({
    "source": [
      "aws.ssm"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventName": [
        "PutParameter",
        "DeleteParameter",
        "LabelParameterVersion"
      ]
    }
  })
  tags                    = {"Name": "SSMParameterChangeRule", "ResourceName": "ssm_change_rule@${local.resource_path}"}
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule                    = aws_cloudwatch_event_rule.ssm_change_rule.name
  target_id               = "LambdaFunctionV1"
  arn                     = aws_lambda_function.config_backup.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id            = "AllowExecutionFromCloudWatch"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.config_backup.function_name
  principal               = "events.amazonaws.com"
  source_arn              = aws_cloudwatch_event_rule.ssm_change_rule.arn
}
