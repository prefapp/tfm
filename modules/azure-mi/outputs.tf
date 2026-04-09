output "id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}
