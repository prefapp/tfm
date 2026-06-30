# Plan: Configure STS AssumeRole DurationSeconds for destination clients

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add Terraform variable `assume_role_duration_seconds` with range validation.
2. Pass `ASSUME_ROLE_DURATION_SECONDS` to Lambda environment.
3. Extend config loading and runtime dataclass to include duration.
4. Update `assume_role` helper to accept optional duration and set `DurationSeconds`.
5. Apply duration to all destination assume-role calls.
6. Update docs and regenerate README.
7. Validate diagnostics/syntax and mark tasks complete.
