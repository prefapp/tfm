# Outputs
output "eventhub_namespace_id" {
  value = azurerm_eventhub_namespace.this.id
}

output "eventhub_id" {
  value = azurerm_eventhub.this.id
}
