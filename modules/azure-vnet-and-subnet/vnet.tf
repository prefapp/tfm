# Resource block for creating Azure virtual networks
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = var.address_spaces
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}
