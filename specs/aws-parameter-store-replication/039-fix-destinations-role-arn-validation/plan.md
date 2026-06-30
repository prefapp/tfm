# Plan: Fix ineffective destinations role ARN format validation

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Replace `can(alltrue([...]))` with a condition that actually checks `alltrue([...])`.
2. Keep safeguards so malformed JSON/object structures don't crash this validation expression.
3. Regenerate module docs with `terraform-docs .`.
4. Run `terraform validate` and diagnostics checks.
