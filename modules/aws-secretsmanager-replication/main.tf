terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Pass DESTINATIONS_JSON and enable_tag_replication as environment variables to the Lambda
  environment = merge(
    {
      DESTINATIONS_JSON      = var.destinations_json
      ENABLE_TAG_REPLICATION = tostring(var.enable_tag_replication)
    },
    var.environment_variables
  )
}

# ---------------------------------------------------------------------------
# Lambda using the official module
# ---------------------------------------------------------------------------

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = var.name
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = "${path.module}/lambda"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = var.tags

  environment_variables = local.environment

  attach_cloudwatch_logs_policy = false

  # Extra IAM permissions for Secrets Manager + STS
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = var.allowed_assume_roles
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = module.lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_cloudtrail" "secrets_data_events" {
  name                          = "${var.prefix}-secrets-data-events"
  is_multi_region_trail         = true
  include_global_service_events = false
  enable_logging                = true
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id

  # No necesitamos management events para este caso
  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::SecretsManager::Secret"
      values = [
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*"
      ]
    }
  }

  tags = var.tags
}
