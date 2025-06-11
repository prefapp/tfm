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

output "rendered_template_content" {
  description = "Cloudformation stack with a iam role to access the S3 bucket and the dynamodb table"
  value       = local.should_upload ? null : local.rendered_template
}

output "s3_template_url" {
  description = "S3 URL of the uploaded template (only if 'upload_cloudformation_role' is true)"
  value       = local.should_upload ? "s3://${var.s3_bucket_cloudformation_role}/${var.s3_bucket_cloudformation_role_key}" : null
}

output "terraform_state_role_arn" {
  description = "ARN of the terraform state role"
  value       = aws_iam_role.this.arn
}

output "terraform_state_role_name" {
  description = "ARN of the terraform state role"
  value       = aws_iam_role.this.id
}
