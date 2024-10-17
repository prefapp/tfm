# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "this" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  soft_delete         = var.soft_delete
  identity {
    type = "SystemAssigned"
  }
}
