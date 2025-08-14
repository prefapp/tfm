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
  value       = local.should_upload ? null : local.cloudformation_template_yaml
}

output "s3_template_url" {
  description = "S3 URL of the uploaded template (only if 'upload_cloudformation_role' is true)"
  value       = local.should_upload ? "s3://${var.s3_bucket_cloudformation_role}/${var.s3_bucket_cloudformation_role_key}" : null
}

output "main_role_arn" {
  description = "Main role ARN"
  value = module.main_oidc_role.iam_role_arn
}

output "aux_role_arn" {
  description = "Auxiliary role ARN"
  value = module.aux_oidc_role[0].iam_role_arn
}
