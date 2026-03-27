# EventBridge rule that matches CloudTrail API calls for AWS Backup and triggers the Lambda function for automatic replication


resource "aws_cloudwatch_event_rule" "rds_backup_job_completed" {
  count       = local.has_cross_account_copy ? 1 : 0
  name        = "backup-job-completed"
  description = "Capture AWS backup point state change"

  event_pattern = jsonencode({
    "source" : ["aws.backup"],
    "detail-type" : ["Recovery Point State Change"],
    "detail" : {
      #   "resourceType" : ["RDS"],
      "backupVaultName" : [for vault in var.aws_backup_vault : vault.vault_name if vault.vault_name != null],
      "status" : ["COMPLETED"],
    }
  })

}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  count = local.has_cross_account_copy ? 1 : 0
  rule  = aws_cloudwatch_event_rule.rds_backup_job_completed[0].name
  arn   = module.lambda_automatic_replication[0].lambda_function_arn
  # Optional: configure retry policy or input transformer if needed
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = local.has_cross_account_copy ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_automatic_replication[0].lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_backup_job_completed[0].arn
}


