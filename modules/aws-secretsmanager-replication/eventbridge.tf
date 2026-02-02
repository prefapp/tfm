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

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.secretsmanager_events.name
  target_id = "lambda"
  arn       = aws_lambda_function.secrets_replicator.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secrets_replicator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secretsmanager_events.arn
}
