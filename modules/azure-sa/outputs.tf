output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "Primary access key for the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint URL."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_endpoints" {
  description = "Primary endpoints for the storage account."
  value = {
    blob  = azurerm_storage_account.this.primary_blob_endpoint
    queue = azurerm_storage_account.this.primary_queue_endpoint
    table = azurerm_storage_account.this.primary_table_endpoint
    file  = azurerm_storage_account.this.primary_file_endpoint
  }
}

output "secondary_blob_endpoint" {
  description = "Secondary blob service endpoint URL."
  value       = azurerm_storage_account.this.secondary_blob_endpoint
}

output "secondary_endpoints" {
  description = "Secondary endpoints for the storage account."
  value = {
    blob  = azurerm_storage_account.this.secondary_blob_endpoint
    queue = azurerm_storage_account.this.secondary_queue_endpoint
    table = azurerm_storage_account.this.secondary_table_endpoint
    file  = azurerm_storage_account.this.secondary_file_endpoint
  }
}

output "container_ids" {
  description = "Map from each container name (for_each key) to the blob container resource ID."
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "share_ids" {
  description = "Map from each file share name to the file share resource ID."
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}

output "queue_ids" {
  description = "Map from each queue name to the queue resource ID."
  value       = { for k, v in azurerm_storage_queue.this : k => v.id }
}

output "table_ids" {
  description = "Map from each table name to the table resource ID."
  value       = { for k, v in azurerm_storage_table.this : k => v.id }
}
