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
  combined_policies = {
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
}

module "main_oidc_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.60.0"
  create_role                    = true
  role_name                      = var.main_role.name
  inline_policy_statements       = [local.combined_policies]
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
  inline_policy_statements       = [local.combined_policies]
  provider_urls                  = try(tolist(var.aux_role.oidc_trust_policies.provider_urls), [])
  oidc_fully_qualified_subjects  = try(tolist(var.aux_role.oidc_trust_policies.fully_qualified_subjects), [])
  oidc_fully_qualified_audiences = try(tolist(var.aux_role.oidc_trust_policies.fully_qualified_audiences), [])
}

# Imprimir el valor de combined_policies para depuración
output "combined_policies" {
  value = local.combined_policies
}
