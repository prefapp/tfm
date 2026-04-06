# Outputs
output "nat_gateway_id" {
  description = "ID of the Azure NAT Gateway resource."
  value       = azurerm_nat_gateway.this.id
}
