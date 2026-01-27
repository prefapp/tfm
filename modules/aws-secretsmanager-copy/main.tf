terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

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

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 30

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

# ---------------------------------------------------------------------------
# EventBridge Rule to detect secret changes (optional)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "secret_change" {
  count       = var.eventbridge_enabled ? 1 : 0
  name        = "${var.name}-secret-change"
  description = "Trigger Lambda when a secret is modified"

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    detail_type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"]
      eventName   = ["PutSecretValue", "UpdateSecret"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.eventbridge_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.secret_change[0].name
  target_id = "lambda"
  arn       = module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.eventbridge_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secret_change[0].arn
}

