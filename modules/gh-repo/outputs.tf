output "repository_id" {
  description = "ID of the created GitHub repository"
  value       = github_repository.this.id
}

output "repository_name" {
  description = "Name of the created repository"
  value       = github_repository.this.name
}

output "repository_full_name" {
  description = "Full name (owner/repo) of the repository"
  value       = github_repository.this.full_name
}

output "repository_html_url" {
  description = "URL to the repository on GitHub"
  value       = github_repository.this.html_url
}

output "repository_visibility" {
  description = "Visibility of the repository"
  value       = github_repository.this.visibility
}

output "default_branch" {
  description = "Default branch name"
  value       = github_branch_default.this.branch
}

output "committed_files" {
  description = "List of files that were committed"
  value       = [for f in var.config.files : f.file]
}

output "repository_variables" {
  description = "List of repository variables created"
  value       = [for v in var.config.variables : v.variableName]
}
