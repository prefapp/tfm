data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name = var.tfbackend_access_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:root",
          ]
        }
      },
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated : "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "state_management" {
  name        = "${var.tfbackend_access_role_name}-state-access"
  description = "Permissions for Terraform state bucket and DynamoDB lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Bucket Permissions
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.tfstate.arn
        Condition = {
          StringEquals = {
            "s3:prefix" : var.tfstate_object_prefix
          }
        }
      },
      # S3 Object Permissions
      {
        Sid    = "S3BucketObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.tfstate.arn}"
      },
      # S3 Object Permissions
      {
        Sid    = "S3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.tfstate.arn}/${var.tfstate_object_prefix}.tflock"
      }
    ]
  })
}

resource "aws_iam_policy" "locks_table" {
  count       = var.locks_table_name == null || var.locks_table_name == "" ? 0 : 1
  name        = "${var.tfbackend_access_role_name}-state-lock"
  description = "Permissions for Terraform state locks DynamoDB table"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # DynamoDB Table Permissions
      {
        Sid    = "DynamoDBLockTableAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.this[0].arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "client" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.state_management.arn
}


resource "aws_iam_role_policy_attachment" "locks_table" {
  count      = var.locks_table_name == null || var.locks_table_name == "" ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.locks_table[0].arn
}


resource "aws_iam_role_policy_attachment" "extra_roles" {
  for_each   = toset(var.backend_extra_roles)
  role       = each.key
  policy_arn = aws_iam_policy.state_management.arn
}

resource "aws_iam_role_policy_attachment" "extra_roles_lock_tables" {
  for_each   = toset(var.backend_extra_roles)
  role       = each.key
  policy_arn = aws_iam_policy.locks_table[0].arn
}

