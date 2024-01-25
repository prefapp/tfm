# Resource block for creating Azure virtual networks
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  # Use the variables for creating each virtual network
  for_each = var.virtual_networks

  # The name of the virtual network is derived from the key in the local.input map
  name                = each.key
  
  # Other properties of the virtual network are derived from the value in the local.input map
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  
  # Tags are also derived from the value in the local.input map
  tags = each.value.tags
  lifecycle {
    ignore_changes = [
      for tag in ignored_tags : tags[tag]
      ]
  }
}
