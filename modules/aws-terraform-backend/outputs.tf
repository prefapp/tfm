output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "dynamodb_locks_table_arn" {
  description = "ARN of the DynamoDB table (empty if not created)"
  value       = var.dynamodb_table_name == "" ? "" : aws_dynamodb_table.this.arn
}
