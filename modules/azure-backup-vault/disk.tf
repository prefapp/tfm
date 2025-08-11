# Role assignment: Backup Contributor al vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_backup_contributor_disk" {
  count = length(var.disk_instances) > 0 ? 1 : 0
  scope                = azurerm_data_protection_backup_vault.this.id
  role_definition_name = "Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Role assignment: Disk Backup Reader a cada disco
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "disk_backup_reader" {
  for_each             = { for instance in var.disk_instances : instance.instance_disk_name => instance }
  scope                = data.azurerm_managed_disk.this[each.value.instance_disk_name].id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Disk backup policies
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk
resource "azurerm_data_protection_backup_policy_disk" "this" {
  for_each                        = { for policy in var.disk_policies : policy.policy_name => policy }
  name                            = each.value.policy_name
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
  for_each                     = { for instance in var.disk_instances : instance.instance_disk_name => instance }
  name                         = each.value.instance_disk_name
  location                     = data.azurerm_resource_group.this.location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  disk_id                      = data.azurerm_managed_disk.this[each.value.instance_disk_name].id
  snapshot_resource_group_name = data.azurerm_resource_group.this.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.policy_key].id

  depends_on = [
    azurerm_role_assignment.vault_backup_contributor_disk,
    azurerm_role_assignment.disk_backup_reader
  ]
}
