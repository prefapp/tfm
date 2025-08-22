# Role assignment: Disk Backup Reader a cada disco
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "disk_backup_reader" {
  for_each             = { for instance in var.disk_instances : instance.name => instance }
  scope                = data.azurerm_managed_disk.this[each.value.name].id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Role assignment: Snapshot RG Contributor a cada disco
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "snapshot_rg_contributor" {
  for_each             = data.azurerm_resource_group.disk_rg
  scope                = each.value.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Disk backup policies
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk
resource "azurerm_data_protection_backup_policy_disk" "this" {
  for_each                        = { for policy in var.disk_policies : policy.name => policy }
  name                            = each.value.name
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  default_retention_duration      = each.value.default_retention_duration
  time_zone                       = try(each.value.time_zone, null)

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : []
    content {
      name     = retention_rule.value.name
      duration = retention_rule.value.duration
      priority = retention_rule.value.priority
      criteria {
        absolute_criteria = try(retention_rule.value.criteria.absolute_criteria, null)
      }
    }
  }
}

# Disk instance backups
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk
resource "azurerm_data_protection_backup_instance_disk" "this" {
  for_each                     = { for instance in var.disk_instances : instance.name => instance }
  name                         = each.value.name
  location                     = data.azurerm_resource_group.disk_rg[each.value.disk_resource_group].location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  disk_id                      = data.azurerm_managed_disk.this[each.value.name].id
  snapshot_resource_group_name = data.azurerm_resource_group.disk_rg[each.value.disk_resource_group].name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.policy_key].id

  depends_on = [
    azurerm_role_assignment.disk_backup_reader,
    azurerm_role_assignment.snapshot_rg_contributor,
    azurerm_role_assignment.vault_backup_contributor
  ]
}
