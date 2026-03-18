output "private_dns_zone_id" {
  description = "ID of the Private DNS Zone."
  value       = azurerm_private_dns_zone.this.id
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS Zone."
  value       = azurerm_private_dns_zone.this.name
}

output "vnet_links" {
  description = "Map of VNet link IDs."
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.link : k => v.id }
}
