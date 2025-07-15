# Backup Vault Azure Data Protection
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  count                        = var.vault != null ? 1 : 0
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

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
