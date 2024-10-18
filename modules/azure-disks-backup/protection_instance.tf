# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk
resource "azurerm_data_protection_backup_instance_disk" "this" {
    for_each                     = { for instance in var.backup_instances : instance.disk_name => instance }
    name                         = each.key
    location                     = data.azurerm_managed_disk.this[each.key].region
    vault_id                     = azurerm_data_protection_backup_vault.this.id
    disk_id                      = data.azurerm_managed_disk.this[each.key].id
    snapshot_resource_group_name = each.value.snapshot_resource_group_name
    backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.backup_policy_name].id
    depends_on = [
        azurerm_role_assignment.this_rg,
        azurerm_role_assignment.this_disk
    ]
}
