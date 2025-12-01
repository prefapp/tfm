#
# S3 Backend Outputs
#
output "tfstate_bucket_arn" {
  description = "ARN of the Terraform State S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "tfstate_bucket_name" {
  description = "Name of the Terraform State S3 bucket"
  value       = aws_s3_bucket.this.id
}

#
# DynamoDB Outputs
#
output "dynamodb_locks_table_arn" {
  description = "ARN of the DynamoDB locks table (empty if not created)"
  value       = var.locks_table_name == null || var.locks_table_name == "" ? "" : aws_dynamodb_table.this[0].arn
}

output "dynamodb_locks_table_name" {
  description = "Name of the DynamoDB locks table (empty if not created)"
  value       = var.locks_table_name == null || var.locks_table_name == "" ? "" : aws_dynamodb_table.this[0].name
}

#
# IAM Role Outputs
#
output "admin_role_arn" {
  description = "ARN of the admin role in the backend account"
  value       = module.admin_oidc_role.iam_role_arn
}

output "admin_role_name" {
  description = "Name of the admin role in the backend account"
  value       = var.roles.admin.name
}

output "readwrite_role_arn" {
  description = "ARN of the readwrite role in the backend account (null if not created)"
  value       = var.roles.readwrite != null ? module.readwrite_oidc_role[0].iam_role_arn : null
}

output "readwrite_role_name" {
  description = "Name of the readwrite role in the backend account (empty if not created)"
  value       = var.roles.readwrite != null ? var.roles.readwrite.name : ""
}

#
# CloudFormation Template Outputs
#
output "cloudformation_template_content" {
  description = "CloudFormation template YAML content (only if not uploaded to S3)"
  value       = local.should_upload ? null : local.cloudformation_template_yaml
}

output "cloudformation_template_s3_url" {
  description = "S3 URL of the uploaded CloudFormation template"
  value       = local.should_upload ? "s3://${var.cloudformation_s3_bucket}/${var.cloudformation_s3_key}/${var.aws_client_account_id}.yaml" : null
}

output "cloudformation_template_s3_https_url" {
  description = "HTTPS URL of the uploaded CloudFormation template"
  value       = local.should_upload ? "https://s3.amazonaws.com/${var.cloudformation_s3_bucket}/${var.cloudformation_s3_key}/${var.aws_client_account_id}.yaml" : null
}

#
# External CloudFormation Role Names (for reference)
#
output "external_admin_role_name" {
  description = "Name of the admin role to be created in the client account via CloudFormation"
  value       = var.roles.admin.external_role_name
}

output "external_readwrite_role_name" {
  description = "Name of the readwrite role to be created in the client account via CloudFormation"
  value       = var.roles.readwrite != null ? var.roles.readwrite.external_role_name : ""
}
