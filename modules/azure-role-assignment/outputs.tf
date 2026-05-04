output "role_assignment_ids" {
  description = "Map from each key in `var.role_assignments` to the created role assignment resource ID."
  value       = { for k, v in azurerm_role_assignment.role_assignment : k => v.id }
}
