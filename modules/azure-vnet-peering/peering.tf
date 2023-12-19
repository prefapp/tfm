# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "origin-to-destination" {
  name                      = var.origin_name_peering
  resource_group_name       = var.origin_resource_group_name
  virtual_network_name      = var.origin_virtual_network_name
  remote_virtual_network_id = data.azurerm_virtual_network.id_virtual_network_destination.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "destination-to-origin" {
  name                      = var.destination_name_peering
  resource_group_name       = var.destination_resource_group_name
  virtual_network_name      = var.destination_virtual_network_name
  remote_virtual_network_id = data.azurerm_virtual_network.id_virtual_network_origin.id
}
