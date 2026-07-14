# EventBridge rule that matches CloudTrail API calls for Secrets Manager (including rotations)
# CloudTrail API call events arrive with source "aws.cloudtrail", not "aws.secretsmanager".
# detail.eventSource narrows the match to Secrets Manager API calls only.
resource "aws_cloudwatch_event_rule" "secretsmanager_api_calls" {
  count       = var.eventbridge_enabled ? 1 : 0
  name        = "${var.prefix}-secretsmanager-cloudtrail-rule"
  description = "Trigger Lambda on Secrets Manager API calls via CloudTrail"
  tags        = var.tags
  event_pattern = jsonencode({
    "source" : ["aws.cloudtrail"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["secretsmanager.amazonaws.com"],
      "eventName" : concat(["PutSecretValue", "CreateSecret"], var.eventbridge_extra_event_names)
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  count = var.eventbridge_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.secretsmanager_api_calls[0].name
  arn   = module.lambda_replication.lambda_function_arn
  # optional: configure retry policy or input transformer if needed
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.eventbridge_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_replication.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secretsmanager_api_calls[0].arn
}


