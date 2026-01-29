data "aws_caller_identity" "current" {}

locals {
  # Extract only the role name from the caller identity ARN in a safe way
  arn_parts = split("/", data.aws_caller_identity.current.arn)
  # Use the second element when available (preserving previous behavior), otherwise fall back to the first
  role_name = length(local.arn_parts) >= 2 ? local.arn_parts[1] : local.arn_parts[0]
}

data "aws_iam_role" "role_used_by_sso" {
  name = local.role_name
}

data "aws_iam_policy_document" "kms_default_statement" {

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

  statement {
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
      type = "AWS"
      identifiers = compact(concat(
        var.administrator_role_name != null ? ["arn:aws:iam::${data.aws_caller_identity.current.id}:role/${var.administrator_role_name}"] : [],
        [data.aws_iam_role.role_used_by_sso.arn]
      ))
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


}
