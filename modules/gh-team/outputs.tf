# Outputs section

output "team_id" {
  description = "ID of the created GitHub team"
  value       = github_team.this.id
}

output "team_slug" {
  description = "Slug of the created GitHub team"
  value       = github_team.this.slug
}

output "team_name" {
  description = "Name of the created GitHub team"
  value       = github_team.this.name
}

output "team_description" {
  description = "Description of the created GitHub team"
  value       = github_team.this.description
}

output "team_privacy" {
  description = "Privacy setting of the team (closed/secret)"
  value       = github_team.this.privacy
}

output "team_members" {
  description = "List of usernames added to the team"
  value       = [for m in var.config.group_members : m.username]
}

output "team_parent_id" {
  description = "Parent team ID (null if none)"
  value       = github_team.this.parent_team_id
}
