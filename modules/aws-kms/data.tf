data "aws_caller_identity" "current" {}

locals {
  # Check if the caller identity is a role by inspecting the ARN
  # Role ARN format: arn:aws:iam::ACCOUNT:role/ROLE_NAME
  # User ARN format: arn:aws:iam::ACCOUNT:user/USER_NAME
  # Assumed role ARN format: arn:aws:sts::ACCOUNT:assumed-role/ROLE_NAME/SESSION_NAME
  is_role = can(regex(":role/", data.aws_caller_identity.current.arn)) || can(regex(":assumed-role/", data.aws_caller_identity.current.arn))
  # Extract only the role name from the caller identity ARN in a safe way
  # Only used when caller is a role (data source has count = 0 when is_role is false)
  arn_parts = split("/", data.aws_caller_identity.current.arn)
  # Consider the ARN valid for role-name extraction only when there is a non-empty second part
  valid_role_name = length(local.arn_parts) >= 2 && trim(local.arn_parts[1], " ") != ""
  # Use the extracted role name only when the ARN format is valid; otherwise leave it empty
  role_name = local.valid_role_name ? local.arn_parts[1] : ""

  # Build list of administrator identifiers
  administrator_identifiers = compact(concat(
    var.administrator_role_name != null ? ["arn:aws:iam::${data.aws_caller_identity.current.id}:role/${var.administrator_role_name}"] : [],
    local.is_role && local.valid_role_name ? [data.aws_iam_role.role_used_by_sso[0].arn] : []
  ))
}

data "aws_iam_role" "role_used_by_sso" {
  count = local.is_role && local.valid_role_name ? 1 : 0
  name  = local.role_name
}

data "aws_iam_policy_document" "kms_default_statement" {
  for_each = toset(concat(var.aws_regions_replica, [var.aws_region]))

  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(local.administrator_identifiers) > 0 ? [1] : []
    content {
      sid    = "Allow access for Key Administrators"
      effect = "Allow"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:RotateKeyOnDemand",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = local.administrator_identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.aws_accounts_access) > 0 ? [1] : []
    content {
      sid    = "Allow account access"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = [for account in var.aws_accounts_access : "arn:aws:iam::${account}:root"]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.user_roles_with_read_write) > 0 ? [1] : []
    content {
      sid    = "Allow account access"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = [for account in var.user_roles_with_read_write : account]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.user_roles_with_read) > 0 ? [1] : []
    content {
      sid    = "Allow account access"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = [for account in var.user_roles_with_read_write : account]
      }
    }
  }
  dynamic "statement" {
    for_each = length(var.aws_accounts_access) > 0 ? [1] : []
    content {
      sid    = "Allow account grant access"
      effect = "Allow"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = [for account in var.aws_accounts_access : "arn:aws:iam::${account}:root"]
      }
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }
  dynamic "statement" {
    for_each = var.via_service != null || var.alias != null ? [1] : []
    content {
      sid    = "Allow access through RDS for all principals in the account that are authorized to use RDS"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = var.via_service == null ? ["${var.alias}.${each.key}.amazonaws.com"] : [for service in var.via_service : "${service}.${each.key}.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "kms:callerAccount"
        values   = [for account in concat(var.aws_accounts_access, [data.aws_caller_identity.current.id]) : account]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:DescribeKey",
      ]
    }
  }
}

