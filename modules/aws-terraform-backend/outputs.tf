output "tfstate_bucket_arn" {
  description = "ARN of the Terraform State S3 bucket"
  value       = aws_s3_bucket.tfstate.arn
}

output "tfstate_bucket_name" {
  description = "Name of the Terraform State S3 bucket"
  value       = aws_s3_bucket.tfstate.id
}

output "dynamodb_locks_table_arn" {
  description = "ARN of the DynamoDB table (empty if not created)"
  value       = var.locks_table_name == "" || var.locks_table_name == null ? "" : aws_dynamodb_table.this[0].arn
}

output "dynamodb_locks_table_name" {
  description = "Name of the DynamoDB table (empty if not created)"
  value       = var.locks_table_name == "" || var.locks_table_name == null ? "" : aws_dynamodb_table.this[0].name
}

output "cloudformation_role_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.cf_role[0].arn
}

output "cloudformation_role_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.cf_role[0].id
}
