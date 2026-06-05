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
  description = "Map containing the protected item ID for the configured file share (only one supported); empty if `backup_share` is not configured."
  value = var.backup_share == null ? {} : {
    for idx, name in var.backup_share.source_file_share_name :
    name => azurerm_backup_protected_file_share.this[idx].id
  }
}

output "blob_backup_policy_id" {
  description = "Resource ID of the blob backup policy; null if `backup_blob` is not configured."
  value       = var.backup_blob != null ? azurerm_data_protection_backup_policy_blob_storage.this[0].id : null
}

output "blob_backup_vault_principal_id" {
  description = "Principal ID of the backup vault managed identity; null if `backup_blob` is not configured or no identity is defined."
  value       = var.backup_blob != null && var.backup_blob.identity_type != null ? azurerm_data_protection_backup_vault.this[0].identity[0].principal_id : null
}

output "file_share_backup_policy_id" {
  description = "Resource ID of the file share backup policy; null if `backup_share` is not configured."
  value       = var.backup_share != null ? azurerm_backup_policy_file_share.this[0].id : null
}

output "blob_backup_role_assignment_id" {
  description = "Role assignment ID granting the backup vault access to the storage account; null if `backup_blob` is not configured or no identity is defined."
  value       = var.backup_blob != null && var.backup_blob.identity_type != null ? azurerm_role_assignment.this[0].id : null
}
