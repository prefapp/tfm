# Backup Vault Azure Data Protection
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  name                         = var.vault.name
  resource_group_name          = data.azurerm_resource_group.name
  location                     = data.azurerm_resource_group.resource_group.location
  datastore_type               = var.vault.datastore_type
  redundancy                   = var.vault.redundancy
  cross_region_restore_enabled = var.vault.cross_region_restore_enabled
  retention_duration_in_days   = var.vault.retention_duration_in_days
  immutability                 = var.vault.immutability
  soft_delete                  = var.vault.soft_delete
  tags                         = local.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Backup policy for Backup Vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy
resource "azurerm_data_protection_backup_policy" "this" {
  for_each = { for p in var.policy : p.name => p }

  name                                   = each.value.name
  vault_id                               = each.value.vault_id
  time_zone                              = each.value.time_zone
  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  vault_default_retention_duration       = each.value.vault_default_retention_duration
  retention_duration                     = each.value.retention_duration

  dynamic "retention_rule" {
    for_each = each.value.retention_rule
    content {
      name     = retention_rule.value.name
      duration = retention_rule.value.duration
      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []
        content {
          days_of_week  = lookup(criteria.value, "days_of_week", null)
          days_of_month = lookup(criteria.value, "days_of_month", null)
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle != null ? [retention_rule.value.life_cycle] : []
        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}
