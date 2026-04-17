output "ruleset_id" {
  description = "The ruleset GraphQL ruleset_id"
  value       = github_organization_ruleset.this.ruleset_id
}

output "node_id" {
  description = "The ruleset GraphQL node_id"
  value       = github_organization_ruleset.this.node_id
}

output "etag" {
  description = "The ruleset etag"
  value       = github_organization_ruleset.this.etag
}
