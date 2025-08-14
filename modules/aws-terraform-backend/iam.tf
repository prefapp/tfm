locals {
  base_policies = [
    {
      Sid      = "S3BucketAccess",
      Effect   = "Allow",
      Action   = ["s3:ListBucket", "s3:GetBucketVersioning"],
      Resource = aws_s3_bucket.tfstate.arn,
      Condition = {
        StringEquals = { "s3:prefix" = [var.tfstate_object_prefix] }
      }
    },
    {
      Sid      = "S3BucketObjectAccess",
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:PutObject"],
      Resource = "${aws_s3_bucket.tfstate.arn}/*"
    },
    {
      Sid      = "S3ObjectAccess",
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      Resource = "${aws_s3_bucket.tfstate.arn}/${var.tfstate_object_prefix}.tflock"
    }
  ]
  dynamodb_policy = var.locks_table_name != null && var.locks_table_name != "" ? [
    {
      Sid      = "DynamoDBLockTableAccess",
      Effect   = "Allow",
      Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"],
      Resource = aws_dynamodb_table.this[0].arn
    }
  ] : []
  assume_role_policy = [
    {
      Sid      = "AssumeRoleAccess",
      Effect   = "Allow",
      Action   = ["sts:AssumeRole"],
      Resource = "arn:aws:iam::${var.aws_client_account_id}:role/${var.main_role.cloudformation_external_account_role}"
    }
  ]
  assume_role_policy_aux = [
    {
      Sid      = "AssumeRoleAccess",
      Effect   = "Allow",
      Action   = ["sts:AssumeRole"],
      Resource = "arn:aws:iam::${var.aws_client_account_id}:role/${var.aux_role.cloudformation_external_account_role}"
    }
  ]
  main_combined_policies = {
    name = "CombinedPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        local.base_policies,
        local.dynamodb_policy,
        local.assume_role_policy
      )
    })
  }
  aux_combined_policies = {
    name = "CombinedPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        local.base_policies,
        local.dynamodb_policy,
        local.assume_role_policy_aux
      )
    })
  }
}
