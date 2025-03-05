# OUTPUTS SECTION
output "policy_definition_ids" {
  value       = [for policy in azurerm_policy_definition.this : policy.id]
  description = "List of all Azure Policy definition IDs"
}

output "policy_definition_names" {
  value       = [for policy in azurerm_policy_definition.this : policy.name]
  description = "List of all Azure Policy definition names"
}

output "resource_policy_assignment_ids" {
  value       = [for assignment in azurerm_resource_policy_assignment.this : assignment.id]
  description = "List of all Azure resource policy assignment IDs"
}

output "resource_group_policy_assignment_ids" {
  value       = [for assignment in azurerm_resource_group_policy_assignment.this : assignment.id]
  description = "List of all Azure resource group policy assignment IDs"
}

output "subscription_policy_assignment_ids" {
  value       = [for assignment in azurerm_subscription_policy_assignment.this : assignment.id]
  description = "List of all Azure subscription policy assignment IDs"
}
