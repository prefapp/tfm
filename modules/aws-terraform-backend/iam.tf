locals {
  base_policies = [
    {
      sid       = "S3BucketAccess"
      effect    = "Allow"
      actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
      resources = [aws_s3_bucket.tfstate.arn]
      condition = {
        test     = "StringEquals"
        variable = "s3:prefix"
        values   = [var.tfstate_object_prefix]
      }
    },
    {
      sid       = "S3BucketObjectAccess"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject"]
      resources = ["${aws_s3_bucket.tfstate.arn}/*"]
    },
    {
      sid       = "S3ObjectAccess"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = ["${aws_s3_bucket.tfstate.arn}/${var.tfstate_object_prefix}.tflock"]
    }
  ]

  dynamodb_policy = var.locks_table_name != null && var.locks_table_name != "" ? [
    {
      sid       = "DynamoDBLockTableAccess"
      effect    = "Allow"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      resources = [aws_dynamodb_table.this[0].arn]
    }
  ] : []

  assume_role_policy = [
    {
      sid       = "AssumeRoleAccess"
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::${var.aws_client_account_id}:role/${var.main_role.cloudformation_external_account_role}"]
    }
  ]

  assume_role_policy_aux = [
    {
      sid       = "AssumeRoleAccess"
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::${var.aws_client_account_id}:role/${var.aux_role.cloudformation_external_account_role}"]
    }
  ]
}

module "main_oidc_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "5.60.0"
  create_role = true
  role_name   = var.main_role.name
  inline_policy_statements = concat(
    local.base_policies,
    local.dynamodb_policy,
    local.assume_role_policy
  )
  provider_urls                  = try(tolist(var.main_role.oidc_trust_policies.provider_urls), [])
  provider_trust_policy_conditions = [{
    test = "StringEquals"
    variable = "${var.main_role.oidc_trust_policies.provider_urls[0]}:aud"
    values = try(tolist(var.main_role.oidc_trust_policies.oidc_audiences), [])
  }]
  oidc_fully_qualified_subjects  = try(tolist(var.main_role.oidc_trust_policies.fully_qualified_subjects), [])
  oidc_subjects_with_wildcards   = try(tolist(var.main_role.oidc_trust_policies.subjects_with_wildcards), [])
}

module "aux_oidc_role" {
  count       = var.create_aux_role ? 1 : 0
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "5.60.0"
  create_role = true
  role_name   = var.aux_role.name
  inline_policy_statements = concat(
    local.base_policies,
    local.dynamodb_policy,
    local.assume_role_policy_aux
  )
  provider_urls                  = try(tolist(var.aux_role.oidc_trust_policies.provider_urls), [])
  oidc_fully_qualified_subjects  = try(tolist(var.aux_role.oidc_trust_policies.fully_qualified_subjects), [])
  provider_trust_policy_conditions = [{
    test = "StringEquals"
    variable = "${var.aux_role.oidc_trust_policies.provider_urls[0]}:aud"
    values = try(tolist(var.aux_role.oidc_trust_policies.oidc_audiences), [])
  }]
  oidc_subjects_with_wildcards   = try(tolist(var.aux_role.oidc_trust_policies.subjects_with_wildcards), [])
}
