output "resource_policy_assignments" {
  description = "List of objects for Azure resource policy assignments, including id, name, and identity principal_id."
  value = [for assignment in azurerm_resource_policy_assignment.this : {
    id           = assignment.id
    name         = assignment.name
    principal_id = try(assignment.identity[0].principal_id, null)
  }]
}

output "resource_group_policy_assignments" {
  description = "List of objects for Azure resource group policy assignments, including id, name, and identity principal_id."
  value = [for assignment in azurerm_resource_group_policy_assignment.this : {
    id           = assignment.id
    name         = assignment.name
    principal_id = try(assignment.identity[0].principal_id, null)
  }]
}

output "subscription_policy_assignments" {
  description = "List of objects for Azure subscription policy assignments, including id, name, and identity principal_id."
  value = [for assignment in azurerm_subscription_policy_assignment.this : {
    id           = assignment.id
    name         = assignment.name
    principal_id = try(assignment.identity[0].principal_id, null)
  }]
}

output "management_group_policy_assignments" {
  description = "List of objects for Azure management group policy assignments, including id, name, and identity principal_id."
  value = [for assignment in azurerm_management_group_policy_assignment.this : {
    id           = assignment.id
    name         = assignment.name
    principal_id = try(assignment.identity[0].principal_id, null)
  }]
}
