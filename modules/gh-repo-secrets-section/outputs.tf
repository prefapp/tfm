output "repository" {
  description = "The repository these secrets belong to"
  value       = var.config.repository
}

output "actions_secret_names" {
  description = "List of created Actions secret names"
  value       = keys(var.config.actions)
}

output "codespaces_secret_names" {
  description = "List of created Codespaces secret names"
  value       = keys(var.config.codespaces)
}

output "dependabot_secret_names" {
  description = "List of created Dependabot secret names"
  value       = keys(var.config.dependabot)
}

output "all_secret_names" {
  description = "Combined list of all secret names"
  value = concat(
    keys(var.config.actions),
    keys(var.config.codespaces),
    keys(var.config.dependabot)
  )
}
