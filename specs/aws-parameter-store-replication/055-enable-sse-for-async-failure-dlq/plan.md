# Plan: Enable SSE for async failure DLQ

1. Update `aws_sqs_queue.lambda_async_failure_dlq` in `eventbridge.tf` to enable SQS-managed SSE.
2. Run `terraform fmt` and `terraform validate` for the module.
3. Update tasks with validation results.
