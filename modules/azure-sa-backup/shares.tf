## BACKUPS FILE SHARES
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
resource "azurerm_recovery_services_vault" "this" {
  count                        = var.backup_share != null ? 1 : 0
  name                         = var.backup_share.recovery_services_vault_name
  resource_group_name          = var.backup_resource_group_name
  location                     = data.azurerm_resource_group.this.location
  sku                          = var.backup_share.sku
  soft_delete_enabled          = var.backup_share.soft_delete_enabled
  storage_mode_type            = var.backup_share.storage_mode_type
  cross_region_restore_enabled = var.backup_share.cross_region_restore_enabled
  tags                         = local.tags
  dynamic "identity" {
    for_each = var.backup_share.identity != null ? [1] : []
    content {
      type         = var.backup_share.identity.type
      identity_ids = var.backup_share.identity.identity_ids
    }
  }
  dynamic "encryption" {
    for_each = var.backup_share.encryption != null ? [1] : []
    content {
      key_id                            = var.backup_share.encryption.key_id
      infrastructure_encryption_enabled = var.backup_share.encryption.infrastructure_encryption_enabled
      user_assigned_identity_id         = var.backup_share.encryption.user_assigned_identity_id
      use_system_assigned_identity      = var.backup_share.encryption.use_system_assigned_identity
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account
resource "azurerm_backup_container_storage_account" "this" {
  count               = var.backup_share != null ? 1 : 0
  resource_group_name = var.backup_resource_group_name
  recovery_vault_name = var.backup_share.recovery_services_vault_name
  storage_account_id  = var.storage_account_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share
resource "azurerm_backup_policy_file_share" "this" {
  count               = var.backup_share != null ? 1 : 0
  name                = var.backup_share.policy_name
  resource_group_name = var.backup_resource_group_name
  recovery_vault_name = var.backup_share.recovery_services_vault_name
  timezone            = var.backup_share.timezone
  backup {
    frequency = var.backup_share.backup.frequency
    time      = var.backup_share.backup.time
  }

  dynamic "retention_daily" {
    for_each = var.backup_share.retention_daily != null ? [1] : []
    content {
      count = var.backup_share.retention_daily.count
    }
  }
  dynamic "retention_weekly" {
    for_each = var.backup_share.retention_weekly != null ? [1] : []
    content {
      count    = var.backup_share.retention_weekly.count
      weekdays = var.backup_share.retention_weekly.weekdays
    }
  }
  dynamic "retention_monthly" {
    for_each = var.backup_share.retention_monthly != null ? [1] : []
    content {
      count    = var.backup_share.retention_monthly.count
      weekdays = var.backup_share.retention_monthly.weekdays
      weeks    = var.backup_share.retention_monthly.weeks
      days     = var.backup_share.retention_monthly.days
    }
  }
  dynamic "retention_yearly" {
    for_each = var.backup_share.retention_yearly != null ? [1] : []
    content {
      count    = var.backup_share.retention_yearly.count
      weekdays = var.backup_share.retention_yearly.weekdays
      weeks    = var.backup_share.retention_yearly.weeks
      months   = var.backup_share.retention_yearly.months

    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share
resource "azurerm_backup_protected_file_share" "this" {
  count                     = var.backup_share != null ? length(var.backup_share.source_file_share_name) : 0
  resource_group_name       = var.backup_resource_group_name
  recovery_vault_name       = var.backup_share.recovery_services_vault_name
  source_storage_account_id = var.storage_account_id
  source_file_share_name    = element(var.backup_share.source_file_share_name, count.index)
  backup_policy_id          = azurerm_backup_policy_file_share.this[count.index].id
}
