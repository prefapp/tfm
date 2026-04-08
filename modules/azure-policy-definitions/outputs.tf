output "policy_definition_ids" {
  description = "IDs of created policy definitions, in lexicographic order of `name` (for_each key)—not necessarily input list order."
  value       = [for policy in azurerm_policy_definition.this : policy.id]
}

output "policy_definition_names" {
  description = "Names of created policy definitions, in lexicographic order of `name`."
  value       = [for policy in azurerm_policy_definition.this : policy.name]
}
