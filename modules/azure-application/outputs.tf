## OUTPUTS SECTION

output "application_client_id" {
    description = "The client ID of the Azure application"
    value       = azuread_application.this.client_id
}

output "application_object_id" {
    description = "The object ID of the Azure application"
    value       = azuread_application.this.object_id
}
