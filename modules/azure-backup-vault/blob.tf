# Role assignment: Storage Account Backup Contributor for each storage account used in blobs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  for_each             = { for k, v in var.blob_instances : v.storage_account_id => v if v.storage_account_id != null }
  scope                = each.key
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Blob backup policies
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage
resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  for_each                               = var.blob_policies
  name                                   = each.value.policy_name
  vault_id                               = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  time_zone                              = each.value.time_zone
  vault_default_retention_duration       = each.value.vault_default_retention_duration

  dynamic "retention_rule" {
    for_each = each.value.retention_rule
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      criteria {
        absolute_criteria      = try(retention_rule.value.criteria.absolute_criteria, null)
        days_of_week           = try(retention_rule.value.criteria.days_of_week, null)
        days_of_month          = try(retention_rule.value.criteria.days_of_month, null)
        months_of_year         = try(retention_rule.value.criteria.months_of_year, null)
        weeks_of_month         = try(retention_rule.value.criteria.weeks_of_month, null)
        scheduled_backup_times = try(retention_rule.value.criteria.scheduled_backup_times, null)
      }
      life_cycle {
        data_store_type = retention_rule.value.life_cycle.data_store_type
        duration        = retention_rule.value.life_cycle.duration
      }
    }
  }
}

# Blob instance backups
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage
resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  for_each                        = var.blob_instances
  name                            = each.value.instance_blob_name
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  location                        = data.azurerm_resource_group.this.location
  storage_account_id              = each.value.storage_account_id
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.this[each.value.policy_key].id
  storage_account_container_names = each.value.storage_account_container_names
  depends_on                      = [azurerm_role_assignment.this]
}
