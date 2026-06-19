output "lambda_automatic_replication_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_automatic_replication.lambda_function_arn
}

output "lambda_automatic_replication_role_arn" {
  description = "IAM role ARN associated with the Lambda"
  value       = aws_iam_role.lambda_automatic_replication.arn
}

output "lambda_manual_replication_arn" {
  description = "ARN of the manual replication Lambda function (if created)"
  value       = try(module.lambda_manual_replication[0].lambda_function_arn, null)
}

output "lambda_manual_replication_role_arn" {
  description = "IAM role ARN for the manual replication Lambda (if created)"
  value       = try(aws_iam_role.lambda_manual_replication[0].arn, null)
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule (if created)"
  value       = try(aws_cloudwatch_event_rule.parameter_store_api_calls[0].arn, null)
}
