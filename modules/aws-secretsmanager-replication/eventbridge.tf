# EventBridge rule that matches CloudTrail API calls for Secrets Manager (including rotations)
resource "aws_cloudwatch_event_rule" "secretsmanager_api_calls" {
  count       = var.eventbridge_enabled ? 1 : 0
  name        = "${var.prefix}-secretsmanager-cloudtrail-rule"
  description = "Trigger Lambda on Secrets Manager API calls via CloudTrail (Create/Put)"
  event_pattern = jsonencode({
    "source" : ["aws.secretsmanager"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventName" : ["PutSecretValue", "CreateSecret"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  count = var.eventbridge_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.secretsmanager_api_calls[0].name
  arn   = module.lambda_automatic_replication.lambda_function_arn
  # optional: configure retry policy or input transformer if needed
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.eventbridge_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_automatic_replication.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secretsmanager_api_calls[0].arn
}


