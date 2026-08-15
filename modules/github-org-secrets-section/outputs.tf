output "organization" {
  description = "The organization these secrets belong to"
  value       = var.config.org
}

output "actions_secret_names" {
  description = "List of created Actions secret names"
  value       = keys(github_actions_organization_secret.this)
}

output "codespaces_secret_names" {
  description = "List of created Codespaces secret names"
  value       = keys(github_codespaces_organization_secret.this)
}

output "dependabot_secret_names" {
  description = "List of created Dependabot secret names"
  value       = keys(github_dependabot_organization_secret.this)
}

output "all_secret_names" {
  description = "Combined list of all secret names"
  value = concat(
    keys(github_actions_organization_secret.this),
    keys(github_codespaces_organization_secret.this),
    keys(github_dependabot_organization_secret.this)
  )
}
