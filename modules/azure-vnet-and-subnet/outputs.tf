# Output the ID of the virtual network
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

# Output the IDs of the subnets with their names as keys
output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}
