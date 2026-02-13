output "bucket_id" {
  description = "Name of the bucket that is created or whose data is obtained"
  value       = var.create_bucket ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
}

output "bucket_arn" {
  description = "ARN of the bucket that is created or whose data is obtained"
  value       = var.create_bucket ? aws_s3_bucket.this[0].arn : data.aws_s3_bucket.this[0].arn
}
output "bucket_domain_name" {
  description = "Domain name of the bucket that is created or whose data is obtained"
  value       = var.create_bucket ? aws_s3_bucket.this[0].bucket_domain_name : data.aws_s3_bucket.this[0].bucket_domain_name
}

## Replication outputs
output "replication_role_arn" {
  description = "ARN of the replication role"
  value       = try(aws_iam_role.replication[0].arn, null)
}

output "replication_destination_bucket_arn" {
  description = "ARN of the replication destination bucket"
  value       = try(var.s3_replication_destination.bucket_arn, null)
}

output "replication_s3_destination_replication_s3_policy_json" {
  description = "JSON policy for S3 replication in the destination bucket, to be applied to that bucket."
  value       = try(data.aws_iam_policy_document.destination_replication_s3_policy[0].json, null)
}