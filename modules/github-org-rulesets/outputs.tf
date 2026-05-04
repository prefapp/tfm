output "ruleset_ids" {
  description = "Map of ruleset logical key to ruleset GraphQL ruleset_id"
  value       = { for k, v in module.ruleset : k => v.ruleset_id }
}

output "node_ids" {
  description = "Map of ruleset logical key to ruleset GraphQL node_id"
  value       = { for k, v in module.ruleset : k => v.node_id }
}

output "ruleset_etags" {
  description = "Map of ruleset logical key to ruleset etag"
  value       = { for k, v in module.ruleset : k => v.etag }
}
