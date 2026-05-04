output "repository" {
  description = "The repository these secrets belong to"
  value       = var.config.repository
}

output "actions_secret_names" {
  description = "List of created Actions secret names"
  value       = keys(github_actions_secret.this)
}

output "codespaces_secret_names" {
  description = "List of created Codespaces secret names"
  value       = keys(github_codespaces_secret.this)
}

output "dependabot_secret_names" {
  description = "List of created Dependabot secret names"
  value       = keys(github_dependabot_secret.this)
}

output "all_secret_names" {
  description = "Combined list of all secret names"
  value = concat(
    keys(github_actions_secret.this),
    keys(github_codespaces_secret.this),
    keys(github_dependabot_secret.this)
  )
}
