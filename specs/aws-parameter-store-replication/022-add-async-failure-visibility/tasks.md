# Tasks: Add async failure visibility for EventBridge-triggered replication

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add async failure visibility variables
- [x] 2. Add DLQ + async invoke config resources
- [x] 3. Add CloudWatch alarms for failure visibility
- [x] 4. Add outputs/docs and regenerate README
- [x] 5. Validate Terraform changes

## Validation Notes

- Added module inputs: `async_failure_visibility_enabled`, `lambda_async_maximum_retry_attempts`, `replication_failure_alarm_actions`.
- Added resources in `eventbridge.tf`: SQS DLQ, queue policy, lambda async invoke config, and CloudWatch alarms.
- Added outputs for DLQ and alarm ARNs in `outputs.tf`.
- Updated docs in `docs/header.md` and regenerated `README.md` with `terraform-docs .`.
- `terraform validate` succeeded (existing provider deprecation warnings unchanged).
