output "id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint URL."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_id" {
  description = "Map from each container name (for_each key) to the blob container resource ID."
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "share_id" {
  description = "Map from each file share name to the file share resource ID."
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}

output "queue_id" {
  description = "Map from each queue name to the queue resource ID."
  value       = { for k, v in azurerm_storage_queue.this : k => v.id }
}

output "table_id" {
  description = "Map from each table name to the table resource ID."
  value       = { for k, v in azurerm_storage_table.this : k => v.id }
}
