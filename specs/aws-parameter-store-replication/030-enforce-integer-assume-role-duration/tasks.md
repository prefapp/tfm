# Tasks: Enforce integer validation for assume_role_duration_seconds

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update `assume_role_duration_seconds` validation in `variables.tf`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics for modified files

## Validation Notes

- Updated `assume_role_duration_seconds` validation to enforce integer-only values with `floor(var.assume_role_duration_seconds) == var.assume_role_duration_seconds` while preserving the `900..43200` range constraints.
- Updated validation error message to explicitly require an integer.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Diagnostics show no errors for modified files.
