# Output the ID of the virtual network
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

# Output the IDs of the subnets with their names as keys
output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

# Output the IDs of the private DNS zones
output "private_dns_zone_ids" {
  value = [for zone in azurerm_private_dns_zone.this : zone.id]
}

# Output the IDs of the private DNS zone virtual network links
output "private_dns_zone_virtual_network_link_ids" {
  value = [for link in azurerm_private_dns_zone_virtual_network_link.this : link.id]
}

# Output the IDs of the virtual network peerings
output "vnet_peering_ids" {
  value = [for peering in azurerm_virtual_network_peering.this : peering.id]
}
