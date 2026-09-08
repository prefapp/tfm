output "id" {
  description = "The Azure resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "name" {
  description = "The name of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.name
}

output "client_id" {
  description = "The client ID (application ID) of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "The service principal object ID of the user-assigned managed identity (use for RBAC assignments referencing this identity)."
  value       = azurerm_user_assigned_identity.this.principal_id
}
