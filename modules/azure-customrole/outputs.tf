output "id" {
  description = "GUID of the custom role definition (`role_definition_id` from the created resource)."
  value       = azurerm_role_definition.this.role_definition_id
}
