## Vault to store backups

resource "aws_backup_vault" "this" {
  for_each = length(var.aws_backup_vault) > 0 ? {
    for vault in var.aws_backup_vault : vault.vault_name => vault
    if vault.vault_name != null
  } : {}
  name        = each.value.vault_name
  region      = try(each.value.vault_region, null)
  kms_key_arn = try(each.value.vault_kms_key_arn, null) != null ? each.value.vault_kms_key_arn : var.aws_kms_key_vault_arn
  tags        = merge(var.tags, try(each.value.vault_tags, {}))
}


resource "aws_backup_plan" "this" {
  for_each = {
    for obj in flatten([
      for vault in var.aws_backup_vault : (
        vault.vault_name != null && vault.plan != null ? [
          for plan in vault.plan : {
            key   = "${vault.vault_name}.${plan.name}"
            vault = vault
            plan  = plan
          }
          if plan.name != null
        ] : []
      )
      ]) : obj.key => {
      vault = obj.vault
      plan  = obj.plan
    }
  }
  name = each.value.plan.name

  rule {
    rule_name                    = try(each.value.plan.rule_name, "tf_example_backup_rule") 
    target_vault_name            = aws_backup_vault.this[each.value.vault.vault_name].name
    schedule                     = try(each.value.plan.schedule, "cron(0 12 * * ? *)")
    schedule_expression_timezone = try(each.value.plan.schedule_expression_timezone, null)
    start_window                 = try(each.value.plan.start_window, null) != null ? each.value.plan.start_window : 60
    completion_window            = try(each.value.plan.completion_window, null) != null ? each.value.plan.completion_window : 11520
    recovery_point_tags          = try(each.value.plan.recovery_point_tags, {}) != {} ? each.value.plan.recovery_point_tags : null
    dynamic "scan_action" {
      for_each = try(each.value.plan.scan_action, [])
      content {
        malware_scanner = try(scan_action.value.malware_scanner, null) != null ? scan_action.value.malware_scanner : null
        scan_mode       = try(scan_action.value.scan_action_type, null) != null ? scan_action.value.scan_action_type : null
      }
    }

    dynamic "copy_action" {
      for_each = try(each.value.plan.copy_action, null) != null ? [1] : var.copy_action_default_values.destination_account_id != null && var.copy_action_default_values.destination_region != null ? [1] : []
      # for_each = try(each.value.plan.copy_action, []) != null ? each.value.plan.copy_action : []
      content {
        destination_vault_arn = try(each.value.plan.copy_action.destination_vault_arn, "arn:aws:backup:${var.copy_action_default_values.destination_region}:${var.copy_action_default_values.destination_account_id}:backup-vault:${aws_backup_vault.this[each.value.vault.vault_name].name}")
        lifecycle {
          cold_storage_after = try(each.value.plan.copy_action.cold_storage_after, var.copy_action_default_values.cold_storage_after) != null ? try(each.value.plan.copy_action.cold_storage_after, var.copy_action_default_values.cold_storage_after) : null
          delete_after       = try(each.value.plan.copy_action.delete_after, var.copy_action_default_values.delete_after) != null ? try(each.value.plan.copy_action.delete_after, var.copy_action_default_values.delete_after) : null
        }
      }
    }

    lifecycle {
      cold_storage_after = try(each.value.plan.cold_storage_after, null)
      delete_after       = try(each.value.plan.delete_after, 14)
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = try(each.value.plan.advanced_backup_setting, []) != null ? each.value.plan.advanced_backup_setting : []
    content {
      backup_options = try(advanced_backup_setting.value.backup_options, { WindowsVSS = "enabled" })
      resource_type  = try(advanced_backup_setting.value.resource_type, "EC2")
    }
  }

  tags = merge(var.tags, try(each.value.plan.tags, {}))
}


resource "aws_backup_selection" "tag_selection" {
  for_each = {
    for obj in flatten([
      for vault in var.aws_backup_vault : (
        vault.vault_name != null && vault.plan != null ? [
          for plan in vault.plan : {
            key   = "${vault.vault_name}.${plan.name}"
            vault = vault
            plan  = plan
          }
          if plan.name != null && plan.backup_selection_conditions != null
        ] : []
      )
      ]) : obj.key => {
      vault = obj.vault
      plan  = obj.plan
    }
  }
  region       = try(each.value.vault.vault_region, null)
  iam_role_arn = aws_iam_role.this.arn
  name         = substr(each.key, 0, 50) # Backup selection name must be 50 characters or fewer
  plan_id      = aws_backup_plan.this[each.key].id
  resources    = ["*"]

  dynamic "condition" {
    for_each = try(each.value.plan.backup_selection_conditions, null) != null ? [each.value.plan.backup_selection_conditions] : []
    content {
      dynamic "string_equals" {
        for_each = try(condition.value.string_equals, []) != null ? condition.value.string_equals : []
        content {
          key   = try(string_equals.value.key, null)
          value = try(string_equals.value.value, null)
        }
      }
      dynamic "string_like" {
        for_each = try(condition.value.string_like, []) != null ? condition.value.string_like : []
        content {
          key   = try(string_like.value.key, null)
          value = try(string_like.value.value, null)
        }
      }
      dynamic "string_not_equals" {
        for_each = try(condition.value.string_not_equals, []) != null ? condition.value.string_not_equals : []
        content {
          key   = try(string_not_equals.value.key, null)
          value = try(string_not_equals.value.value, null)
        }
      }
      dynamic "string_not_like" {
        for_each = try(condition.value.string_not_like, []) != null ? condition.value.string_not_like : []
        content {
          key   = try(string_not_like.value.key, null)
          value = try(string_not_like.value.value, null)
        }
      }
    }
  }
}

resource "aws_backup_selection" "resource_selection" {
  for_each = {
    for obj in flatten([
      for vault in var.aws_backup_vault : (
        vault.vault_name != null && vault.plan != null ? [
          for plan in vault.plan : {
            key   = "${vault.vault_name}.${plan.name}"
            vault = vault
            plan  = plan
          }
          if plan.name != null && plan.backup_selection_arn_resources != null
        ] : []
      )
      ]) : obj.key => {
      vault = obj.vault
      plan  = obj.plan
    }
  }
  region       = try(each.value.vault.vault_region, null)
  iam_role_arn = aws_iam_role.this.arn
  name         = substr(each.key, 0, 50) # Backup selection name must be 50 characters or fewer
  plan_id      = aws_backup_plan.this[each.key].id

  resources = each.value.plan.backup_selection_arn_resources
}