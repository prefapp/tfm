resource "aws_cloudwatch_event_rule" "secretsmanager_events" {
  name        = "${var.prefix}-secretsmanager-events"
  description = "Trigger Lambda on Secrets Manager updates"

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"]
      eventName   = ["PutSecretValue", "UpdateSecret"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "secret_change" {
  count       = var.eventbridge_enabled ? 1 : 0
  name        = "${var.name}-secret-change"
  description = "Trigger Lambda when a secret is modified"

  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"]
      eventName   = ["PutSecretValue", "UpdateSecret"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.eventbridge_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.secret_change[0].name
  target_id = "lambda"
  arn       = module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.eventbridge_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secret_change[0].arn
}


