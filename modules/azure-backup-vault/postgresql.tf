# Role assignment: Backup Contributor to the vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_backup_contributor_postgresql" {
  scope                = azurerm_data_protection_backup_vault.postgresql.id
  role_definition_name = "Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Role assignment: PostgreSQL Flexible Server Backup Contributor to each server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "postgresql_backup_contributor" {
  for_each             = var.postgresql_instances
  scope                = each.value.server_id
  role_definition_name = "PostgreSQL Flexible Server Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Role assignment: PostgreSQL Flexible Server Long Term Retention Backup on the server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "postgresql_ltr_backup" {
  for_each             = var.postgresql_instances
  scope                = each.value.server_id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup"
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Role assignment: Reader on the resource group of the server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "postgresql_rg_reader" {
  for_each             = var.postgresql_instances
  scope                = each.value.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity.principal_id
}

# Backup policy for PostgreSQL Flexible Server
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql
resource "azurerm_data_protection_backup_policy_postgresql" "this" {
  for_each                        = var.postgresql_policies
  name                            = each.value.policy_name
  vault_name                      = azurerm_data_protection_backup_vault.this.name
  resource_group_name             = azurerm_data_protection_backup_vault.this.resource_group_name
  default_retention_duration      = each.value.default_retention_duration
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = try(each.value.time_zone, null)
  dynamic "retention_rule" {
    for_each = each.value.retention_rule
    content {
      name     = retention_rule.value.name
      duration = retention_rule.value.duration
      priority = retention_rule.value.priority
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
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server
resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "this" {
  for_each         = var.postgresql_instances
  name             = each.value.instance_name
  location         = data.azurerm_resource_group.resource_group.location
  vault_id         = azurerm_data_protection_backup_vault.this.id
  server_id        = each.value.server_id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql.this[each.value.policy_key].id
  depends_on = [
    azurerm_role_assignment.vault_backup_contributor_postgresql,
    azurerm_role_assignment.postgresql_backup_contributor,
    azurerm_role_assignment.postgresql_ltr_backup,
    azurerm_role_assignment.postgresql_rg_reader
  ]
}


