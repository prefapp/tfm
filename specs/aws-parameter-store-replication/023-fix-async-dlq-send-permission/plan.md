# Plan: Fix async DLQ delivery permission on Lambda execution role

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add `aws_iam_role_policy` resource granting `sqs:SendMessage` to the DLQ ARN.
2. Gate the policy with `eventbridge_enabled && async_failure_visibility_enabled`.
3. Validate Terraform.
4. Mark tasks complete.
