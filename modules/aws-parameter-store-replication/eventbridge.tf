# EventBridge rule that captures native SSM Parameter Store events
resource "aws_cloudwatch_event_rule" "parameter_store_api_calls" {
  count       = var.eventbridge_enabled ? 1 : 0
  name        = local.eventbridge_rule_name
  description = "Trigger Lambda on Parameter Store parameter creation and updates"
  event_pattern = jsonencode({
    "source" : ["aws.ssm"],
    "detail-type" : ["Parameter Store Change"],
    "detail" : {
      "operation" : ["Create", "Update"]
    }
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  count = var.eventbridge_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.parameter_store_api_calls[0].name
  arn   = module.lambda_replication.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.eventbridge_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_replication.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.parameter_store_api_calls[0].arn
}

resource "aws_sqs_queue" "lambda_async_failure_dlq" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  name                    = local.lambda_async_failure_dlq_name
  sqs_managed_sse_enabled = true
  tags                    = local.common_tags
}

data "aws_iam_policy_document" "lambda_async_failure_dlq_policy" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  statement {
    sid    = "AllowLambdaAsyncFailureDestination"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.lambda_async_failure_dlq[0].arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.lambda_replication.lambda_function_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "lambda_async_failure_dlq" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  queue_url = aws_sqs_queue.lambda_async_failure_dlq[0].id
  policy    = data.aws_iam_policy_document.lambda_async_failure_dlq_policy[0].json
}

resource "aws_lambda_function_event_invoke_config" "replication_async" {
  count = var.eventbridge_enabled ? 1 : 0

  function_name          = module.lambda_replication.lambda_function_name
  maximum_retry_attempts = var.lambda_async_maximum_retry_attempts

  dynamic "destination_config" {
    for_each = var.async_failure_visibility_enabled ? [1] : []
    content {
      on_failure {
        destination = aws_sqs_queue.lambda_async_failure_dlq[0].arn
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_async_errors" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  alarm_name          = local.lambda_async_errors_alarm_name
  alarm_description   = "Async replication Lambda errors detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.replication_failure_alarm_actions

  dimensions = {
    FunctionName = module.lambda_replication.lambda_function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_async_failure_dlq_visible" {
  count = var.eventbridge_enabled && var.async_failure_visibility_enabled ? 1 : 0

  alarm_name          = local.lambda_async_dlq_alarm_name
  alarm_description   = "Messages visible in replication async failure DLQ"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.replication_failure_alarm_actions

  dimensions = {
    QueueName = aws_sqs_queue.lambda_async_failure_dlq[0].name
  }

  tags = local.common_tags
}
