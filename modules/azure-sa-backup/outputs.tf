output "blob_data_protection_vault_id" {
  description = "Resource ID of the Data Protection backup vault for blob backup; null if `backup_blob` is not configured."
  value       = var.backup_blob != null ? azurerm_data_protection_backup_vault.this[0].id : null
}

output "blob_backup_instance_id" {
  description = "Resource ID of the blob backup instance; null if `backup_blob` is not configured."
  value       = var.backup_blob != null ? azurerm_data_protection_backup_instance_blob_storage.this[0].id : null
}

output "file_share_recovery_services_vault_id" {
  description = "Resource ID of the Recovery Services vault for file share backup; null if `backup_share` is not configured."
  value       = var.backup_share != null ? azurerm_recovery_services_vault.this[0].id : null
}

output "file_share_protected_item_ids" {
  description = "Map from each name in `backup_share.source_file_share_name` to its backup protected item resource ID; empty if `backup_share` is not configured."
  value = var.backup_share == null ? {} : {
    for idx, name in var.backup_share.source_file_share_name :
    name => azurerm_backup_protected_file_share.this[idx].id
  }
}
