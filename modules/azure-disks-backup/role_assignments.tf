# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this_rg" {
    scope                = data.azurerm_resource_group.this.id
    role_definition_name = "Disk Backup Reader"
    principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
    depends_on = [
        azurerm_data_protection_backup_vault.this
    ]
}

resource "azurerm_role_assignment" "this_disk" {
    for_each             = data.azurerm_managed_disk.this
    scope                = each.value.id
    role_definition_name = "Disk Backup Reader"
    principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
    depends_on = [
        azurerm_data_protection_backup_vault.this
    ]
}
