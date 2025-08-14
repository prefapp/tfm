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
        length(local.base_policies) > 0 ? local.base_policies : [],
        length(local.dynamodb_policy) > 0 ? local.dynamodb_policy : [],
        length(local.local.assume_role_policy) > 0 ? local.assume_role_policy : []
      )
    })
  }
  aux_combined_policies = {
    name = "CombinedPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        length(local.base_policies) > 0 ? local.base_policies : [],
        length(local.dynamodb_policy) > 0 ? local.dynamodb_policy : [],
        length(local.local.assume_role_policy_aux) > 0 ? local.assume_role_policy_aux : []
      )
    })
  }
}

module "main_oidc_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.60.0"
  create_role                    = true
  role_name                      = var.main_role.name
  inline_policy_statements       = [local.main_combined_policies]
  provider_urls                  = try(tolist(var.main_role.oidc_trust_policies.provider_urls), [])
  oidc_fully_qualified_subjects  = try(tolist(var.main_role.oidc_trust_policies.fully_qualified_subjects), [])
  oidc_fully_qualified_audiences = try(tolist(var.main_role.oidc_trust_policies.fully_qualified_audiences), [])
}

module "aux_oidc_role" {
  count                          = var.create_aux_role ? 1 : 0
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.60.0"
  create_role                    = true
  role_name                      = var.aux_role.name
  inline_policy_statements       = [local.aux_combined_policies]
  provider_urls                  = try(tolist(var.aux_role.oidc_trust_policies.provider_urls), [])
  oidc_fully_qualified_subjects  = try(tolist(var.aux_role.oidc_trust_policies.fully_qualified_subjects), [])
  oidc_fully_qualified_audiences = try(tolist(var.aux_role.oidc_trust_policies.fully_qualified_audiences), [])
}

# Debug print combined policies
output "main_combined_policies" {
  value = local.main_combined_policies
}
output "aux_combined_policies" {
  value = local.aux_combined_policies
}
