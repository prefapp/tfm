output "lambda_automatic_replication_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_automatic_replication.lambda_function_arn
}

output "lambda_automatic_replication_role_arn" {
  description = "IAM role ARN associated with the Lambda"
  value       = module.lambda_automatic_replication.lambda_role_arn
}

output "lambda_manual_replication_arn" {
  description = "ARN of the manual replication Lambda function (if created)"
  value       = try(module.lambda_manual_replication[0].lambda_function_arn, null)
}

output "lambda_manual_replication_role_arn" {
  description = "IAM role ARN for the manual replication Lambda (if created)"
  value       = try(module.lambda_manual_replication[0].lambda_role_arn, null)
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule (if created)"
  value       = try(aws_cloudwatch_event_rule.secretsmanager_api_calls[0].arn, null)
}

output "cloudtrail_arn" {
  value       = local.cloudtrail_arn
  description = "ARN of the CloudTrail used (existing or created)."
}

output "cloudtrail_name" {
  value       = local.cloudtrail_name
  description = "Name of the CloudTrail used (existing or created)."
}

output "s3_bucket_id" {
  value       = local.s3_bucket_id
  description = "S3 bucket name used for CloudTrail logs (existing or created)."
}

output "using_existing_cloudtrail" {
  value       = local.using_existing_cloudtrail
  description = "True if an existing CloudTrail was provided."
}

output "using_existing_s3_bucket" {
  value       = local.using_existing_s3_bucket
  description = "True if an existing S3 bucket name was provided."
}

