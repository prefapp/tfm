output "organization_settings_id" {
  description = "GitHub organization ID used by github_organization_settings."
  value       = github_organization_settings.this.id
}

output "billing_email" {
  description = "Billing email configured for the organization."
  value       = github_organization_settings.this.billing_email
  sensitive   = true
}

output "default_repository_permission" {
  description = "Default repository permission configured for organization members."
  value       = github_organization_settings.this.default_repository_permission
}

output "members_can_create_repositories" {
  description = "Whether members can create repositories in the organization."
  value       = github_organization_settings.this.members_can_create_repositories
}

output "advanced_security_enabled_for_new_repositories" {
  description = "Whether GitHub Advanced Security is enabled for new repositories."
  value       = github_organization_settings.this.advanced_security_enabled_for_new_repositories
}
