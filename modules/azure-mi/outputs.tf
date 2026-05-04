output "id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "Principal (object) ID of the identity; use for Azure RBAC `principal_id`."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Client (application) ID of the identity; use when the workload must select this UAMI explicitly."
  value       = azurerm_user_assigned_identity.this.client_id
}
