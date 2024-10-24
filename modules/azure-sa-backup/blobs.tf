## BACKUPS BLOBS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  count               = var.backup_blob != null ? 1 : 0
  name                = var.backup_blob.vault_name
  resource_group_name = var.backup_resource_group_name
  location            = data.azurerm_resource_group.this.location
  datastore_type      = var.backup_blob.datastore_type
  redundancy          = var.backup_blob.redundancy
  tags                = data.azurerm_resource_group.this.tags
  dynamic "identity" {
    for_each = var.backup_blob.identity_type != null ? [1] : []
    content {
      type = var.backup_blob.identity_type
    }
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  count                = var.backup_blob != null && can(var.backup_blob.identity_type) ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = var.backup_blob.role_assignment
  principal_id         = azurerm_data_protection_backup_vault.this[0].identity[0].principal_id
  depends_on           = [azurerm_data_protection_backup_vault.this]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage
resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  count                           = var.backup_blob != null ? 1 : 0
  name                            = var.backup_blob.policy.name
  vault_id                        = azurerm_data_protection_backup_vault.this[0].id
  backup_repeating_time_intervals = var.backup_blob.policy.backup_repeating_time_intervals
  dynamic "retention_rule" {
    for_each = var.backup_blob.policy.retention_rule != null ? var.backup_blob.policy.retention_rule : []
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
  count                           = var.backup_blob != null ? 1 : 0
  name                            = var.backup_blob.instance_blob_name
  vault_id                        = azurerm_data_protection_backup_vault.this[0].id
  location                        = data.azurerm_resource_group.this.location
  storage_account_id              = var.storage_account_id
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.this[0].id
  storage_account_container_names = var.backup_blob.storage_account_container_names
}
