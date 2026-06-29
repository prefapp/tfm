output "lambda_replication_arn" {
  description = "ARN of the unified replication Lambda function"
  value       = module.lambda_replication.lambda_function_arn
}

output "lambda_replication_role_arn" {
  description = "IAM role ARN for the replication Lambda"
  value       = aws_iam_role.lambda_replication.arn
}

# Backward compatibility outputs (deprecated, pointing to unified function)
output "lambda_automatic_replication_arn" {
  description = "DEPRECATED: Use lambda_replication_arn. ARN of the replication Lambda function"
  value       = module.lambda_replication.lambda_function_arn
}

output "lambda_automatic_replication_role_arn" {
  description = "DEPRECATED: Use lambda_replication_role_arn. IAM role ARN for the replication Lambda"
  value       = aws_iam_role.lambda_replication.arn
}

output "lambda_manual_replication_arn" {
  description = "DEPRECATED: Use lambda_replication_arn. ARN of the replication Lambda function"
  value       = module.lambda_replication.lambda_function_arn
}

output "lambda_manual_replication_role_arn" {
  description = "DEPRECATED: Use lambda_replication_role_arn. IAM role ARN for the replication Lambda"
  value       = aws_iam_role.lambda_replication.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule (if created)"
  value       = try(aws_cloudwatch_event_rule.parameter_store_api_calls[0].arn, null)
}
