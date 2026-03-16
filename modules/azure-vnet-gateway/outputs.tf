output "virtual_network_gateway_id" {
  description = "The ID of the created Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "public_ip_ids" {
  description = "The IDs of the Public IPs used by the gateway."
  value       = [for cfg in azurerm_virtual_network_gateway.this.ip_configuration : cfg.public_ip_address_id]
}

output "nat_rule_ids" {
  description = "List of IDs of the NAT rules created (if any)."
  value       = try([for rule in azurerm_virtual_network_gateway_nat_rule.this : rule.id], [])
}
