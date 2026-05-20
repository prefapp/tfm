output "vault_id" {
  description = "Resource ID of the Data Protection backup vault."
  value       = azurerm_data_protection_backup_vault.this.id
}
