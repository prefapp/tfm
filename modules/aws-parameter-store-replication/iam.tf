###############################################################################
# Lambda execution roles
###############################################################################

# Separate role creation for automatic replication Lambda
resource "aws_iam_role" "lambda_automatic_replication" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.common_tags
}

# Conditional role creation for manual replication Lambda
resource "aws_iam_role" "lambda_manual_replication" {
  count              = var.manual_replication_enabled ? 1 : 0
  name               = local.lambda_manual_role_name
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
  role = aws_iam_role.lambda_automatic_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListTagsForResource"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_manual_ssm_read" {
  count = var.manual_replication_enabled ? 1 : 0
  name  = "${local.lambda_manual_role_name}-ssm-read"
  role  = aws_iam_role.lambda_manual_replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListTagsForResource"
          ]
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
# This is created per destination account to allow cross-account access
resource "aws_iam_role_policy" "lambda_ssm_write_destinations" {
  name = "${local.lambda_role_name}-ssm-write-destinations"
  role = aws_iam_role.lambda_automatic_replication.id

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

resource "aws_iam_role_policy" "lambda_manual_ssm_write_destinations" {
  count = var.manual_replication_enabled ? 1 : 0
  name  = "${local.lambda_manual_role_name}-ssm-write-destinations"
  role  = aws_iam_role.lambda_manual_replication[0].id

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
  role  = aws_iam_role.lambda_automatic_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:ViaService" = "ssm.*.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_manual_kms" {
  count = var.manual_replication_enabled && length(local.destinations) > 0 ? 1 : 0
  name  = "${local.lambda_manual_role_name}-kms"
  role  = aws_iam_role.lambda_manual_replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:ViaService" = "ssm.*.amazonaws.com"
          }
        }
      }
    ]
  })
}

###############################################################################
# Attach AWSLambdaBasicExecutionRole for CloudWatch Logs
###############################################################################

resource "aws_iam_role_policy_attachment" "lambda_automatic_basic_execution" {
  role       = aws_iam_role.lambda_automatic_replication.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_manual_basic_execution" {
  count      = var.manual_replication_enabled ? 1 : 0
  role       = aws_iam_role.lambda_manual_replication[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
