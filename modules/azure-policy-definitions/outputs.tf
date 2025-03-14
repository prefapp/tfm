# OUTPUTS SECTION
output "policy_definition_ids" {
  value       = [for policy in azurerm_policy_definition.this : policy.id]
  description = "List of all Azure Policy definition IDs"
}

output "policy_definition_names" {
  value       = [for policy in azurerm_policy_definition.this : policy.name]
  description = "List of all Azure Policy definition names"
}
