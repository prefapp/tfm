output "id" {
  description = "Resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "FQDN of the server (hostname for client connection strings)."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "administrator_password_key_vault_secret_id" {
  description = "Resource ID of the Key Vault secret for the administrator password."
  value       = azurerm_key_vault_secret.password_create.id
}
