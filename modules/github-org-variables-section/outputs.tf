output "managed_variables" {
  description = "List of managed organization variable names."
  value       = keys(github_actions_organization_variable.this)
}

output "variable_ids" {
  description = "Map of variable names to their resource IDs."
  value = {
    for name, resource in github_actions_organization_variable.this :
    name => resource.id
  }
}
