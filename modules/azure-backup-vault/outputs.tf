output "vault_id" {
  value       = length(azurerm_data_protection_backup_vault.this) > 0 ? azurerm_data_protection_backup_vault.this[0].id : null
  description = "ID of the backup vault (if exists)"
}
