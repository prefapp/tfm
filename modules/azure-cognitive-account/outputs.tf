output "cognitive_account_id" {
  description = "Azure resource ID of the Cognitive Services account."
  value       = azurerm_cognitive_account.this.id
}

output "cognitive_account_name" {
  description = "Name of the Cognitive Services account."
  value       = azurerm_cognitive_account.this.name
}

output "endpoint" {
  description = "Endpoint URL of the Cognitive Services account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "custom_subdomain_name" {
  description = "Custom subdomain name assigned to the account."
  value       = azurerm_cognitive_account.this.custom_subdomain_name
}

output "tags" {
  description = "Tags applied to the account."
  value       = azurerm_cognitive_account.this.tags
}
