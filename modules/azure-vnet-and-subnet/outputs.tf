# Output the ID of the virtual network
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

# Output the IDs of the subnets with their names as keys
output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

# Output the IDs of the virtual network peerings with their names as keys
output "vnet_peering_ids" {
  value = { for name, peering in azurerm_virtual_network_peering.this : name => peering.id }
}
