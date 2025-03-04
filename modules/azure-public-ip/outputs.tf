# Outputs
output "public_ip_id" {
  value = azurerm_public_ip.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}
