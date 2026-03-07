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

output "repository_topics" {
  description = "List of topics applied to the repository"
  value       = github_repository.this.topics
}
