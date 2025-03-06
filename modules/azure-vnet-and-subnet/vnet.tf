# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Resource block for creating Azure virtual networks
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network.name
  location            = var.virtual_network.location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_network.address_space
  tags                = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}
