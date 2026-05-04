output "id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.this.id
}

output "network_security_rule_id" {
  description = "Map of rule keys (from `rules`) to network security rule resource IDs."
  value       = { for k, v in azurerm_network_security_rule.this : k => v.id }
}
