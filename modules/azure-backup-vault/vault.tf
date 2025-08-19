# Role assignment: Backup Contributor to the vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_backup_contributor" {
  count                = azurerm_data_protection_backup_vault.this != null ? 1 : 0
  scope                = azurerm_data_protection_backup_vault.this.id
  role_definition_name = "Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

# Backup Vault Azure Data Protection
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  name                         = var.vault.name
  resource_group_name          = data.azurerm_resource_group.this.name
  location                     = data.azurerm_resource_group.this.location
  datastore_type               = var.vault.datastore_type
  redundancy                   = var.vault.redundancy
  cross_region_restore_enabled = var.vault.cross_region_restore_enabled
  retention_duration_in_days   = var.vault.retention_duration_in_days
  immutability                 = var.vault.immutability
  soft_delete                  = var.vault.soft_delete
  tags                         = local.tags
  depends_on                   = [ azurerm_role_assignment.vault_backup_contributor ]

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
