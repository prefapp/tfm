output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
output "bucket_domain_name" {
  value = aws_s3_bucket.this.bucket_domain_name
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