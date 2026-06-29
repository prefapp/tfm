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
