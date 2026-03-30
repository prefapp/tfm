data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "this" {
  for_each = var.aws_backup_vault != [] ? {
    for vault in var.aws_backup_vault : vault.vault_name => vault
    if vault.vault_name != null
  } : {}
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "backup:DescribeBackupVault",
      "backup:DeleteBackupVault",
      "backup:PutBackupVaultAccessPolicy",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:GetBackupVaultAccessPolicy",
      "backup:StartBackupJob",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultNotifications"
    ]

    resources = [aws_backup_vault.this[each.key].arn]
  }
}

data "aws_iam_policy_document" "source_copy" {
  for_each = var.aws_backup_vault != [] ? {
    for vault in var.aws_backup_vault : vault.vault_name => vault
    if(vault.vault_name != null && var.source_account_id != null)
  } : {}
  source_policy_documents = [
    data.aws_iam_policy_document.this[each.key].json
  ]
  statement {
    effect = "Allow"
    sid    = "AllowSourceAccountCopy-${var.source_account_id}"
    principals {
      type        = "AWS"
      identifiers = [var.source_account_id]
    }

    actions = [
      "backup:CopyIntoBackupVault"
    ]

    resources = ["*"]
  }
}
resource "aws_backup_vault_policy" "this" {
  for_each = length(var.aws_backup_vault) > 0 ? {
    for vault in var.aws_backup_vault : vault.vault_name => vault
    if vault.vault_name != null
  } : {}
  backup_vault_name = aws_backup_vault.this[each.key].name
  policy            = var.source_account_id != null ? data.aws_iam_policy_document.source_copy[each.key].json : data.aws_iam_policy_document.this[each.key].json
  region            = try(each.value.vault_region, null)
}

## Role for selection of backups

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "this" {
  count              = length(var.aws_backup_vault) != 0 ? 1 : 0
  name_prefix        = "backupselection-role-"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.aws_backup_vault) != 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.this[0].name
}