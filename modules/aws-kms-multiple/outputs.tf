output "key_arns" {
  description = "Map of KMS key name to key ARN"
  value       = { for k, v in module.multiple-kms : k => v.key_arn }
}

output "key_ids" {
  description = "Map of KMS key name to key ID"
  value       = { for k, v in module.multiple-kms : k => v.key_id }
}

output "alias_arns" {
  description = "Map of KMS key name to alias ARN"
  value       = { for k, v in module.multiple-kms : k => v.alias_arn }
}

output "alias_names" {
  description = "Map of KMS key name to alias name"
  value       = { for k, v in module.multiple-kms : k => v.alias_name }
}

output "replica_key_arns" {
  description = "Map of KMS key name to replica key ARNs per region"
  value       = { for k, v in module.multiple-kms : k => v.replica_key_arns }
}

output "replica_key_ids" {
  description = "Map of KMS key name to replica key IDs per region"
  value       = { for k, v in module.multiple-kms : k => v.replica_key_ids }
}
