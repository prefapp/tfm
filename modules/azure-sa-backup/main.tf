# DATA SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.storage_account_resource_group_name
}

# RESOURCES SECTION
resource "azurerm_resource_group" "this" {
  name     = var.backup_resource_group_name
  location = data.azurerm_resource_group.this.location
  tags     = data.azurerm_resource_group.this.tags
}
