output "id" {
  description = "Resource ID of the public IP prefix."
  value       = azurerm_public_ip_prefix.this.id
}

output "ip_prefix" {
  description = "IP prefix range allocated by Azure (CIDR notation)."
  value       = azurerm_public_ip_prefix.this.ip_prefix
}
