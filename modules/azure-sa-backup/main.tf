# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# RESOURCES SECTION
## BACKUPS FILE SHARES
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
resource "azurerm_recovery_services_vault" "this" {
  name                         = var.backup_share.recovery_services_vault_name
  resource_group_name          = data.azurerm_resource_group.this.name
  location                     = data.azurerm_resource_group.this.location
  sku                          = var.backup_share.sku
  soft_delete_enabled          = var.backup_share.soft_delete_enabled
  storage_mode_type            = var.backup_share.storage_mode_type
  cross_region_restore_enabled = var.backup_share.cross_region_restore_enabled
  tags                         = data.azurerm_resource_group.this.tags
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
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account
resource "azurerm_backup_container_storage_account" "this" {
  resource_group_name = data.azurerm_resource_group.this.name
  recovery_vault_name = var.backup_share.recovery_services_vault_name
  storage_account_id  = var.storage_account_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share
resource "azurerm_backup_policy_file_share" "this" {
  name                = var.backup_share.policy_name
  resource_group_name = data.azurerm_resource_group.this.name
  recovery_vault_name = var.backup_share.recovery_services_vault_name
  timezone            = var.backup_share.timezone
  backup {
    frequency = var.backup_share.backup.frequency
    time      = var.backup_share.backup.time
  }
  retention_daily {
    count = var.backup_share.retention_daily.count
  }
  retention_weekly {
    count    = var.backup_share.retention_weekly.count
    weekdays = var.backup_share.retention_weekly.weekdays
  }
  retention_monthly {
    count    = var.backup_share.retention_monthly.count
    weekdays = var.backup_share.retention_monthly.weekdays
    weeks    = var.backup_share.retention_monthly.weeks
  }
  retention_yearly {
    count    = var.backup_share.retention_yearly.count
    weekdays = var.backup_share.retention_yearly.weekdays
    weeks    = var.backup_share.retention_yearly.weeks
    months   = var.backup_share.retention_yearly.months
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share
resource "azurerm_backup_protected_file_share" "this" {
  for_each                  = var.backup_share != null ? { for name in var.backup_share.source_file_share_name : name => name } : {}
  resource_group_name       = data.azurerm_resource_group.this.name
  recovery_vault_name       = var.backup_share.recovery_services_vault_name
  source_storage_account_id = var.storage_account_id
  source_file_share_name    = each.value
  backup_policy_id          = azurerm_backup_policy_file_share.this.id
}

## BACKUPS BLOBS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  name                = var.backup_blob.vault_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  datastore_type      = var.backup_blob.datastore_type
  redundancy          = var.backup_blob.redundancy
  tags                = data.azurerm_resource_group.this.tags
  identity {
    type = var.backup_blob.identity.type
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  scope                = var.storage_account_id
  role_definition_name = var.backup_blob.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
  depends_on           = [azurerm_data_protection_backup_vault.this]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage
resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  name                            = var.backup_blob.policy.name
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = var.backup_blob.policy.backup_repeating_time_intervals
  dynamic "retention_rule" {
    for_each = var.backup_blob.policy.retention_rule
    content {
      name = retention_rule.value.name
      criteria {
        absolute_criteria      = retention_rule.value.criteria.absolute_criteria
        days_of_month          = retention_rule.value.criteria.days_of_month
        days_of_week           = retention_rule.value.criteria.days_of_week
        months_of_year         = retention_rule.value.criteria.months_of_year
        scheduled_backup_times = retention_rule.value.criteria.scheduled_backup_times
        weeks_of_month         = retention_rule.value.criteria.weeks_of_month
      }
      life_cycle {
        data_store_type = retention_rule.value.life_cycle.data_store_type
        duration        = retention_rule.value.life_cycle.duration
      }
      priority = retention_rule.value.priority
    }
  }
  time_zone                              = var.backup_blob.policy.time_zone
  vault_default_retention_duration       = var.backup_blob.policy.vault_default_retention_duration
  operational_default_retention_duration = var.backup_blob.policy.operational_default_retention_duration
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage
resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  name               = var.backup_blob.instance_blob_name
  vault_id           = azurerm_data_protection_backup_vault.this.id
  location           = data.azurerm_resource_group.this.location
  storage_account_id = var.storage_account_id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = var.storage_account_id
  for_each           = var.lifecycle_policy_rule != null ? { for rule in var.lifecycle_policy_rule : rule.name => rule } : {}
  rule {
    name    = each.value.name
    enabled = each.value.enabled
    filters {
      prefix_match = each.value.filters.prefix_match
      blob_types   = each.value.filters.blob_types
    }
    actions {
      base_blob { delete_after_days_since_creation_greater_than = each.value.actions.base_blob.delete_after_days_since_creation_greater_than }
      snapshot { delete_after_days_since_creation_greater_than = each.value.actions.snapshot.delete_after_days_since_creation_greater_than }
      version { delete_after_days_since_creation = each.value.actions.version.delete_after_days_since_creation }
    }
  }
}
