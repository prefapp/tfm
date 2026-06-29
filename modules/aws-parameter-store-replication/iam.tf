###############################################################################
# Lambda execution role (unified for all invocation modes)
###############################################################################

resource "aws_iam_role" "lambda_replication" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.common_tags
}

# Lambda assume role policy
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

###############################################################################
# IAM Policies
###############################################################################

# Policy for reading parameters from current account
resource "aws_iam_role_policy" "lambda_ssm_read" {
  name = "${local.lambda_role_name}-ssm-read"
  role = aws_iam_role.lambda_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = concat(
            [
              "ssm:GetParameter",
              "ssm:GetParameters"
            ],
            var.enable_tag_replication ? ["ssm:ListTagsForResource"] : []
          )
          Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
        }
      ],
      var.enable_full_sync ? [
        {
          Effect = "Allow"
          Action = [
            "ssm:DescribeParameters"
          ]
          Resource = "*"
        }
      ] : []
    )
  })
}

# Policy for writing parameters to destination accounts
resource "aws_iam_role_policy" "lambda_ssm_write_destinations" {
  name = "${local.lambda_role_name}-ssm-write-destinations"
  role = aws_iam_role.lambda_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = distinct(concat(
          var.allowed_assume_roles,
          [for dest in local.destinations : dest.role_arn]
        ))
      }
    ]
  })
}

# KMS policy for encryption/decryption (if needed)
resource "aws_iam_role_policy" "lambda_kms" {
  count = length(local.destinations) > 0 ? 1 : 0
  name  = "${local.lambda_role_name}-kms"
  role  = aws_iam_role.lambda_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_async_failure_dlq_send" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  name = "${local.lambda_role_name}-async-failure-dlq-send"
  role = aws_iam_role.lambda_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.lambda_async_failure_dlq[0].arn
      }
    ]
  })
}

###############################################################################
# Attach AWSLambdaBasicExecutionRole for CloudWatch Logs
###############################################################################

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_replication.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
