# Plan: Add async failure visibility for EventBridge-triggered replication

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add variables to enable/disable async failure visibility and configure retry/alarm actions.
2. Add naming locals for DLQ/alarm resources.
3. Add resources: SQS DLQ + queue policy + lambda event invoke config + CloudWatch alarms.
4. Add outputs for DLQ and alarm ARNs.
5. Update docs and regenerate README.
6. Validate Terraform and close tasks.
