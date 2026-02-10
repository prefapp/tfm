output "key_id" {
  description = "The globally unique identifier for the KMS key"
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "The name of the KMS key alias (null if not created)"
  value       = var.alias != null ? aws_kms_alias.this[0].name : null
}

output "alias_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key alias (null if not created)"
  value       = var.alias != null ? aws_kms_alias.this[0].arn : null
}

output "replica_key_ids" {
  description = "Map of replica region to KMS replica key IDs"
  value       = { for region, key in aws_kms_replica_key.replica : region => key.key_id }
}

output "replica_key_arns" {
  description = "Map of replica region to KMS replica key ARNs"
  value       = { for region, key in aws_kms_replica_key.replica : region => key.arn }
}

output "replica_alias_arns" {
  description = "Map of replica region to KMS replica alias ARNs (empty if alias not created)"
  value       = { for region, alias in aws_kms_alias.this_replica : region => alias.arn }
}
