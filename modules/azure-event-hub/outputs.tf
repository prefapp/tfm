output "eventhub_namespace_id" {
  description = "Resource ID of the Event Hubs namespace."
  value       = azurerm_eventhub_namespace.this.id
}

output "eventhub_id" {
  description = "Map of event hub keys to their Azure resource IDs."
  value       = { for k, v in azurerm_eventhub.this : k => v.id }
}
