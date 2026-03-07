output "actions_secrets" {
  description = "List of Action secrets created"
  value       = [for k, v in var.config.actions : v.secretName]
}

output "codespaces_secrets" {
  description = "List of Codespaces secrets created"
  value       = [for k, v in var.config.codespaces : v.secretName]
}

output "dependabot_secrets" {
  description = "List of Dependabot secrets created"
  value       = [for k, v in var.config.dependabot : v.secretName]
}

output "all_secret_names" {
  description = "Combined list of all secret names"
  value = concat(
    [for v in var.config.actions : v.secretName],
    [for v in var.config.codespaces : v.secretName],
    [for v in var.config.dependabot : v.secretName]
  )
}
