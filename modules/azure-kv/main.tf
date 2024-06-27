# DATA SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

## https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.resource_group
}

# RESOURCES SECTION
## https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = data.azurerm_resource_group.this.location
  resource_group_name         = data.azurerm_resource_group.this.name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  enable_rbac_authorization   = true
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name = var.sku_name
  tags = data.azurerm_resource_group.this.tags
}


