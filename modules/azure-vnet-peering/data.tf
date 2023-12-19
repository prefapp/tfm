# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "id_virtual_network_origin" {
  name                = var.origin_virtual_network_name
  resource_group_name = var.origin_resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "id_virtual_network_destination" {
  name                = var.destination_virtual_network_name
  resource_group_name = var.destination_resource_group_name
}
