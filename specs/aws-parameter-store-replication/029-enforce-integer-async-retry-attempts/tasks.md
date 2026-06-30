# Tasks: Enforce integer validation for async retry attempts

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update `lambda_async_maximum_retry_attempts` validation in `variables.tf`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics for modified files

## Validation Notes

- Updated `variables.tf` validation for `lambda_async_maximum_retry_attempts` to enforce integer-only values with `floor(var.lambda_async_maximum_retry_attempts) == var.lambda_async_maximum_retry_attempts` while keeping the existing `0..2` range constraints.
- Updated validation error message to explicitly require an integer.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Diagnostics show no errors for modified files.
