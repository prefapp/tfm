output "vault_disk_id" {
  value = azurerm_data_protection_backup_vault.disk.id
}

output "vault_blob_id" {
  value = azurerm_data_protection_backup_vault.blob.id
}

output "vault_kubernetes_services_id" {
  value = azurerm_data_protection_backup_vault.kubernetes.id
}

output "vault_postresql_flexible_id" {
  value = azurerm_data_protection_backup_vault.postgresql.id
}

output "vault_mysql_flexible_id" {
  value = azurerm_data_protection_backup_vault.mysql.id
}
