# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault
resource "azurerm_data_protection_backup_vault" "blob" {
  count               = var.backup_blob != null ? 1 : 0
  name                = var.backup_blob.vault_name
  resource_group_name = data.azurerm_resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  datastore_type      = var.backup_blob.datastore_type
  redundancy          = var.backup_blob.redundancy
  tags                = local.tags
  identity {
    type = "SystemAssigned"
    }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Blob instance backup
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage
resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  count                           = var.backup_blob.instance_name != null ? 1 : 0
  name                            = var.backup_blob.instance_blob_name
  vault_id                        = azurerm_data_protection_backup_vault.blob.id
  location                        = data.azurerm_resource_group.resource_group.location
  storage_account_id              = var.backup_blob.storage_account_id
  backup_policy_id                = #Policy module
  storage_account_container_names = var.backup_blob.storage_account_container_names

  depends_on = [azurerm_role_assignment.this_rg,
                azurerm_role_assignment.this_blob
  ]
}
