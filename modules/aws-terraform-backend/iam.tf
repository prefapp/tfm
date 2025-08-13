## we will use the official OIDC role module to create the role
## terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc

module "main_oidc_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "5.60.0"
  create_role = true
  role_name   = var.main_role.name

  provider_urls = length(var.main_role.oidc_trust_policies) == 0 ? [] : tolist(var.main_role.oidc_trust_policies.provider_urls)

  oidc_fully_qualified_subjects  = length(var.main_role.oidc_trust_policies) == 0 ? [] : tolist(var.main_role.oidc_trust_policies.fully_qualified_subjects)
  oidc_fully_qualified_audiences = length(var.main_role.oidc_trust_policies) == 0 ? [] : tolist(var.main_role.oidc_trust_policies.fully_qualified_audiences)
}


module "aux_oidc_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "5.60.0"
  create_role = true
  role_name   = var.aux_role.name

  provider_urls = length(var.aux_role.oidc_trust_policies) == 0 ? [] : tolist(var.aux_role.oidc_trust_policies.provider_urls)

  role_policy_arns               = length(var.aux_role.oidc_trust_policies) == 0 ? [] : tolist(var.aux_role.oidc_trust_policies.role_policy_arns)
  oidc_fully_qualified_subjects  = length(var.aux_role.oidc_trust_policies) == 0 ? [] : tolist(var.aux_role.oidc_trust_policies.fully_qualified_subjects)
  oidc_fully_qualified_audiences = length(var.aux_role.oidc_trust_policies) == 0 ? [] : tolist(var.aux_role.oidc_trust_policies.fully_qualified_audiences)
}

# main role for the terraform backend.
# It can be assumed by the root user of the AWS account
resource "aws_iam_role" "this" {
  name = var.main_role.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::${local.main_account_id}:root",
            ]
          }
        }
      ],
      var.create_oidc_trust_relationship ? [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS : [module.main_oidc_role.cloudformation_external_account_role]
        }
      }] : []
    )
  })
}

resource "aws_iam_policy" "this" {
  name        = "TerraformBackendPolicy"
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
      [
        # STS AssumeRole Permissions
        {
          Sid      = "AssumeRoleAccess"
          Action   = "sts:AssumeRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::${var.aws_client_account_id}:role/${var.main_role.cloudformation_external_account_role}"
        }
      ]
    )
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# Optional role. This role needs access to the terraform state,
# and should be referenced in the read-only role in the client account
# We allow a specific role in the client account to assume this role
# The trust relationship allows an external account to assume this role
# but will be limited with an attached policy that specifies an external role in that account.
resource "aws_iam_role" "that" {
  count = var.create_aux_role ? 1 : 0

  name = var.aux_role.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::${local.aux_account_id}:root",
            ]
          }
        }
      ],
      var.create_oidc_trust_relationship ? [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS : [module.aux_oidc_role.cloudformation_external_account_role]
        }
      }] : []
    )
  })
}


resource "aws_iam_policy" "that" {
  count = var.create_aux_role ? 1 : 0

  name        = "TerraformBackendAuxPolicy"
  description = "Permissions for Terraform state in aux role"
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
      [
        # STS AssumeRole Permissions
        {
          Sid      = "AssumeRoleAccess"
          Action   = "sts:AssumeRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::${var.aws_client_account_id}:role/${var.aux_role.cloudformation_external_account_role}"
        }
      ]
    )
  })
}


resource "aws_iam_role_policy_attachment" "that" {
  count      = var.create_aux_role ? 1 : 0
  role       = aws_iam_role.that[0].name
  policy_arn = aws_iam_policy.that[0].arn
}
