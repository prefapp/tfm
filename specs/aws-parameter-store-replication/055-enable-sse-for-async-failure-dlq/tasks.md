# Tasks: Enable SSE for async failure DLQ

- [x] 1. Enable SQS-managed SSE on async failure DLQ
- [x] 2. Run Terraform formatting and validation
- [x] 3. Record outcomes and close task list

## Validation Notes

- Updated `eventbridge.tf` queue resource `aws_sqs_queue.lambda_async_failure_dlq` with `sqs_managed_sse_enabled = true`.
- Ran `terraform fmt *.tf` in module directory.
- Ran `terraform validate` in module directory: **valid**.
- Validation produced pre-existing deprecation warnings about provider attributes in `iam.tf` (no errors).
