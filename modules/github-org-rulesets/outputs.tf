output "ruleset_ids" {
  description = "Map of ruleset logical key to ruleset GraphQL ruleset_id"
  value       = { for k, v in github_organization_ruleset.this : k => v.ruleset_id }
}

output "node_ids" {
  description = "Map of ruleset logical key to ruleset GraphQL node_id"
  value       = { for k, v in github_organization_ruleset.this : k => v.node_id }
}

output "ruleset_etags" {
  description = "Map of ruleset logical key to ruleset etag"
  value       = { for k, v in github_organization_ruleset.this : k => v.etag }
}
