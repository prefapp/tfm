resource "aws_iam_role" "admin_tfstate_role" {
  name = var.tfbackend_access_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::${var.aws_account_id}:root",
            ]
          }
        }
      ],
      var.create_github_iam ? [{
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
      }] : []
    )
  })
}


resource "aws_iam_policy" "full" {
  name        = var.tfbackend_access_role_name
  description = "Permissions for Terraform state"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
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
              "s3:prefix" = ["${var.tfstate_object_prefix}"]
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
          Resource = "${aws_s3_bucket.tfstate.arn}/*"
        },
        # S3 Lock File Permissions
        {
          Sid    = "S3ObjectAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = "${aws_s3_bucket.tfstate.arn}/${var.tfstate_object_prefix}.tflock"
        },
      ],
      # If locks_table_name is present, add permissions to locks table
      var.locks_table_name == null || var.locks_table_name == "" ? [] :
      [
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
      ],
      # Permissions to assume role
      [
        # STS AssumeRole Permissions
        {
          Sid      = "AssumeRoleAccess"
          Action   = "sts:AssumeRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::*:role/${var.cloudformation_admin_role_for_client_account}"
        }
      ]
    )
  })
}


resource "aws_iam_policy" "limited" {
  name        = "${var.tfbackend_access_role_name}-extra"
  description = "Permissions for Terraform state"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
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
              "s3:prefix" = ["${var.tfstate_object_prefix}"]
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
          Resource = "${aws_s3_bucket.tfstate.arn}/*"
        },
        # S3 Lock File Permissions
        {
          Sid    = "S3ObjectAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = "${aws_s3_bucket.tfstate.arn}/${var.tfstate_object_prefix}.tflock"
        },
      ],
      # If locks_table_name is present, add permissions to locks table
      var.locks_table_name == null || var.locks_table_name == "" ? [] :
      [
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
    )
  })
}


resource "aws_iam_role_policy_attachment" "client" {
  role       = aws_iam_role.admin_tfstate_role.name
  policy_arn = aws_iam_policy.full.arn
}



resource "aws_iam_role_policy_attachment" "extra_roles" {
  for_each   = toset(var.backend_extra_roles)
  role       = each.key
  policy_arn = aws_iam_policy.limited.arn
}


resource "aws_iam_role" "readonly_terraform_state" {
  count = var.readonly_account_id ? 1 : 0

  name = var.readonly_tfstate_access_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::${var.readonly_account_id}:root",
            ]
          }
        }
      ],
      # Permissions to assume role
      [
        # STS AssumeRole Permissions
        {
          Sid      = "AssumeRoleAccess"
          Action   = "sts:AssumeRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::*:role/${var.cloudformation_readonly_role_for_client_account}"
        }
      ],
      var.create_github_iam ? [{
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated : "arn:aws:iam::${var.readonly_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository}:*"
          }
        }
      }] : []
    )
  })
}

resource "aws_iam_policy" "readonly_s3_policy" {
  count = var.readonly_account_id ? 1 : 0

  name = var.readonly_tfstate_access_role_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::terraform-state",
          "arn:aws:s3:::terraform-state/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_readonly_policy" {
  count      = var.readonly_account_id ? 1 : 0
  role       = aws_iam_role.readonly_terraform_state[0].name
  policy_arn = aws_iam_policy.readonly_s3_policy[0].arn
}
