output "virtual_network_gateway_id" {
  description = "The ID of the created Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "public_ip_id" {
  description = "The ID of the Public IP used by the gateway."
  value       = azurerm_virtual_network_gateway.this.ip_configuration[0].public_ip_address_id
}

output "nat_rule_ids" {
  description = "List of IDs of the NAT rules created (if any)."
  value       = try([for rule in azurerm_virtual_network_gateway_nat_rule.this : rule.id], [])
}
