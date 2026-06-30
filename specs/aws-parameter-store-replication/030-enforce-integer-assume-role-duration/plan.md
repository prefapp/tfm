# Plan: Enforce integer validation for assume_role_duration_seconds

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Extend `assume_role_duration_seconds` validation condition in `variables.tf` to include integer check.
2. Update validation error message to mention integer requirement.
3. Regenerate module README with `terraform-docs .`.
4. Validate diagnostics for modified files.
