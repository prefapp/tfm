# Tasks: Fix async DLQ delivery permission on Lambda execution role

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add conditional execution-role `sqs:SendMessage` policy to DLQ
- [x] 2. Validate Terraform changes

## Validation Notes

- Added `aws_iam_role_policy.lambda_async_failure_dlq_send` in `iam.tf`.
- Policy is gated with `var.eventbridge_enabled && var.async_failure_visibility_enabled`.
- Policy grants `sqs:SendMessage` on `aws_sqs_queue.lambda_async_failure_dlq[0].arn` to `aws_iam_role.lambda_replication`.
- `terraform validate` succeeded (existing provider deprecation warnings unchanged).
