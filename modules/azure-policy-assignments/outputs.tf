output "resource_policy_assignment_ids" {
  description = "List of all Azure resource policy assignment IDs"
  value       = [for assignment in azurerm_resource_policy_assignment.this : assignment.id]
}

output "resource_group_policy_assignment_ids" {
  description = "List of all Azure resource group policy assignment IDs"
  value       = [for assignment in azurerm_resource_group_policy_assignment.this : assignment.id]
}

output "subscription_policy_assignment_ids" {
  description = "List of all Azure subscription policy assignment IDs"
  value       = [for assignment in azurerm_subscription_policy_assignment.this : assignment.id]
}

output "management_group_policy_assignment_ids" {
  description = "List of all Azure management group policy assignment IDs"
  value       = [for assignment in azurerm_management_group_policy_assignment.this : assignment.id]
}
