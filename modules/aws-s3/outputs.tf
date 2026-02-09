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
  value = aws_iam_role.replication.arn
}

output "replication_destination_bucket_arn" {
  value = var.s3_destination_bucket_arn
}

output "replication_s3_destination_replication_s3_policydestination_policy" {
  value = data.aws_iam_policy_document.destination_replication_s3_policy.json
}