output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_role_arn" {
  description = "IAM role ARN associated with the Lambda"
  value       = module.lambda.lambda_role_arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule (if created)"
  value       = try(aws_cloudwatch_event_rule.secret_change[0].arn, null)
}
