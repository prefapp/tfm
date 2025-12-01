locals {
  # Base S3 policies for backend access
  s3_base_policies = [
    {
      sid       = "S3BucketAccess"
      effect    = "Allow"
      actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
      resources = [aws_s3_bucket.this.arn]
      condition = {
        test     = "StringEquals"
        variable = "s3:prefix"
        values   = [var.tfstate_object_prefix]
      }
    },
    {
      sid       = "S3ObjectReadWrite"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = ["${aws_s3_bucket.this.arn}/${var.tfstate_object_prefix}/*"]
    }
  ]

  # DynamoDB policy (only if table exists)
  dynamodb_policies = var.locks_table_name != null && var.locks_table_name != "" ? [
    {
      sid       = "DynamoDBLockTableAccess"
      effect    = "Allow"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      resources = [aws_dynamodb_table.this[0].arn]
    }
  ] : []

  # AssumeRole policy for admin role
  admin_assume_role_policy = var.roles.admin.external_role_name != null && var.roles.admin.external_role_name != "" ? [
    {
      sid       = "AssumeExternalAdminRole"
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::${var.aws_client_account_id}:role/${var.roles.admin.external_role_name}"]
    }
  ] : []

  # AssumeRole policy for readwrite role
  readwrite_assume_role_policy = var.roles.readwrite != null && var.roles.readwrite.external_role_name != null && var.roles.readwrite.external_role_name != "" ? [
    {
      sid       = "AssumeExternalReadWriteRole"
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::${var.aws_client_account_id}:role/${var.roles.readwrite.external_role_name}"]
    }
  ] : []

  # Combined policies for each role
  admin_policies     = concat(local.s3_base_policies, local.dynamodb_policies, local.admin_assume_role_policy)
  readwrite_policies = concat(local.s3_base_policies, local.dynamodb_policies, local.readwrite_assume_role_policy)

  # Determine if OIDC is configured
  oidc_enabled = var.oidc_provider_url != null && var.oidc_provider_url != ""

  # Extract provider URL without https://
  oidc_provider = local.oidc_enabled ? replace(var.oidc_provider_url, "https://", "") : ""

  # OIDC subjects for admin role
  admin_oidc_subjects = try(var.oidc_subjects["admin"], { exact = [], wildcard = [] })

  # OIDC subjects for readwrite role
  readwrite_oidc_subjects = try(var.oidc_subjects["readwrite"], { exact = [], wildcard = [] })
}

#
# Admin Role
#
module "admin_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.60.0"

  create_role = true
  role_name   = var.roles.admin.name

  # Inline policies for S3, DynamoDB, and AssumeRole
  inline_policy_statements = local.admin_policies

  # OIDC configuration
  provider_urls                 = local.oidc_enabled ? [var.oidc_provider_url] : []
  oidc_fully_qualified_subjects = local.admin_oidc_subjects.exact
  oidc_subjects_with_wildcards  = local.admin_oidc_subjects.wildcard

  provider_trust_policy_conditions = local.oidc_enabled ? [
    {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = var.oidc_audiences
    }
  ] : []

  tags = var.tags
}

#
# ReadWrite Role (optional)
#
module "readwrite_oidc_role" {
  count   = var.roles.readwrite != null ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.60.0"

  create_role = true
  role_name   = var.roles.readwrite.name

  # Inline policies for S3, DynamoDB, and AssumeRole
  inline_policy_statements = local.readwrite_policies

  # OIDC configuration
  provider_urls                 = local.oidc_enabled ? [var.oidc_provider_url] : []
  oidc_fully_qualified_subjects = local.readwrite_oidc_subjects.exact
  oidc_subjects_with_wildcards  = local.readwrite_oidc_subjects.wildcard

  provider_trust_policy_conditions = local.oidc_enabled ? [
    {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = var.oidc_audiences
    }
  ] : []

  tags = var.tags
}
