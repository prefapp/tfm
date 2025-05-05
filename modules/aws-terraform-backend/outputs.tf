output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}


output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table (empty if not created)"
  value       = var.dynamodb_table_name != "" ? aws_dynamodb_table.terraform_locks.arn : ""
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table (empty if not created)"
  value       = var.dynamodb_table_name != "" ? aws_dynamodb_table.terraform_locks.name : ""
}