output "application_client_id" {
  description = "Application (client) ID of the app registration."
  value       = azuread_application.this.client_id
}

output "application_object_id" {
  description = "Object ID of the app registration."
  value       = azuread_application.this.object_id
}
