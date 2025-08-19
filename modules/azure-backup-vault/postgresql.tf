# Role assignment: PostgreSQL Flexible Server Long Term Retention Backup on the server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "postgresql_ltr_backup" {
  for_each             = { for instance in var.postgresql_instances : instance.name => instance }
  scope                = each.value.server_id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Assign Reader role once per unique PostgreSQL resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "postgresql_rg_reader" {
  for_each             = data.azurerm_resource_group.postgresql_rg
  scope                = each.value.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Backup policy for PostgreSQL Flexible Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_pro
resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "this" {
  for_each                        = local.postgresql_policies_by_name
  name                            = each.value.name
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = try(each.value.time_zone, null)
  default_retention_rule {
    life_cycle {
      data_store_type = try(each.value.default_retention_rule.life_cycle.data_store_type, "VaultStore")
      duration        = each.value.default_retention_rule.life_cycle.duration
    }
  }
  dynamic "retention_rule" {
    for_each = try(each.value.retention_rule, [])
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        data_store_type = try(retention_rule.value.life_cycle.data_store_type, "VaultStore")
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

# Backup instance for PostgreSQL Flexible Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_pro
resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "this" {
  for_each         = { for instance in var.postgresql_instances : instance.name => instance }
  name             = each.value.name
  location         = data.azurerm_resource_group.this.location
  vault_id         = azurerm_data_protection_backup_vault.this.id
  server_id        = each.value.server_id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.this[each.value.policy_key].id
  depends_on = [
    azurerm_role_assignment.postgresql_ltr_backup,
    azurerm_role_assignment.postgresql_rg_reader,
    azurerm_role_assignment.vault_backup_contributor
  ]
}
