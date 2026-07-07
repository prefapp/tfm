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

output "lambda_async_failure_dlq_arn" {
  description = "ARN of the async failure DLQ for replication Lambda (if created)"
  value       = try(aws_sqs_queue.lambda_async_failure_dlq[0].arn, null)
}

output "lambda_async_failure_dlq_url" {
  description = "URL of the async failure DLQ for replication Lambda (if created)"
  value       = try(aws_sqs_queue.lambda_async_failure_dlq[0].id, null)
}

output "lambda_async_errors_alarm_arn" {
  description = "ARN of the async errors CloudWatch alarm (if created)"
  value       = try(aws_cloudwatch_metric_alarm.lambda_async_errors[0].arn, null)
}

output "lambda_async_failure_dlq_alarm_arn" {
  description = "ARN of the async failure DLQ visibility CloudWatch alarm (if created)"
  value       = try(aws_cloudwatch_metric_alarm.lambda_async_failure_dlq_visible[0].arn, null)
}
