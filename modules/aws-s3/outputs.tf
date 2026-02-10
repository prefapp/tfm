output "bucket_id" {
  value = var.create_bucket ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
}

output "bucket_arn" {
  value = var.create_bucket ? aws_s3_bucket.this[0].arn : data.aws_s3_bucket.this[0].arn
}
output "bucket_domain_name" {
  value = var.create_bucket ? aws_s3_bucket.this[0].bucket_domain_name : data.aws_s3_bucket.this[0].bucket_domain_name
}

## Replication outputs
output "replication_role_arn" {
  value = try(aws_iam_role.replication[0].arn, null)
}

output "replication_destination_bucket_arn" {
  value = try(var.s3_replication_destination.bucket_arn, null)
}

output "replication_s3_destination_replication_s3_policydestination_policy" {
  value = try(data.aws_iam_policy_document.destination_replication_s3_policy[0].json, null)
}