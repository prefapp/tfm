output "dns_zone_id" {
  description = "ID of the DNS Zone."
  value       = azurerm_dns_zone.this.id
}

output "dns_zone_name" {
  description = "Name of the DNS Zone."
  value       = azurerm_dns_zone.this.name
}
