output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table (empty if not created)"
  value       = var.dynamodb_table_name != "" ? aws_dynamodb_table.terraform_locks[0].name : ""
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table (empty if not created)"
  value       = var.dynamodb_table_name != "" ? aws_dynamodb_table.terraform_locks[0].arn : ""
}