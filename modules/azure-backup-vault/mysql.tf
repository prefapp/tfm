# Role assignment: Backup Contributor to the vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_backup_contributor_mysql" {
  count = length(var.mysql_instances) > 0 ? 1 : 0
  scope                = azurerm_data_protection_backup_vault.this[0].id
  role_definition_name = "Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this[0].identity[0].principal_id
}

# Role assignment: MySQL Flexible Server Backup Contributor to each server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "mysql_backup_contributor" {
  for_each             = var.mysql_instances
  scope                = each.value.server_id
  role_definition_name = "MySQL Flexible Server Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this[0].identity[0].principal_id
}

# Role assignment: Reader on the resource group of the server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "mysql_rg_reader" {
  for_each             = var.mysql_instances
  scope                = each.value.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this[0].identity[0].principal_id
}

# Backup policy for MySQL Flexible Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_mysql_flexible_server
resource "azurerm_data_protection_backup_policy_mysql_flexible_server" "this" {
  for_each                        = var.mysql_policies
  name                            = each.value.policy_name
  vault_id                        = azurerm_data_protection_backup_vault.this[0].id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = try(each.value.time_zone, null)
  dynamic "default_retention_rule" {
    for_each = try(each.value.default_retention_rule, [])
    content {
      life_cycle {
        duration        = default_retention_rule.value.life_cycle.duration
        data_store_type = default_retention_rule.value.life_cycle.data_store_type
      }
    }
  }
  dynamic "retention_rule" {
    for_each = try(each.value.retention_rule, [])
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        data_store_type = retention_rule.value.life_cycle.data_store_type
        duration        = retention_rule.value.life_cycle.duration
      }
      criteria {
        absolute_criteria      = try(retention_rule.value.criteria.absolute_criteria, null)
        days_of_week           = try(retention_rule.value.criteria.days_of_week, null)
        months_of_year         = try(retention_rule.value.criteria.months_of_year, null)
        weeks_of_month         = try(retention_rule.value.criteria.weeks_of_month, null)
        scheduled_backup_times = try(retention_rule.value.criteria.scheduled_backup_times, null)
      }
    }
  }
}

# Backup instance for MySQL Flexible Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_mysql_flexible_server
resource "azurerm_data_protection_backup_instance_mysql_flexible_server" "this" {
  for_each         = var.mysql_instances
  name             = each.value.instance_name
  location         = data.azurerm_resource_group.this.location
  vault_id         = azurerm_data_protection_backup_vault.this[0].id
  server_id        = each.value.server_id
  backup_policy_id = azurerm_data_protection_backup_policy_mysql_flexible_server.this[each.value.policy_key].id
  depends_on = [
    azurerm_role_assignment.vault_backup_contributor_mysql,
    azurerm_role_assignment.mysql_backup_contributor,
    azurerm_role_assignment.mysql_rg_reader
  ]
}
