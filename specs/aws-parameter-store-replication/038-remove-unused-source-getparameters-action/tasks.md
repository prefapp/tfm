# Tasks: Remove unused source-account `ssm:GetParameters` permission

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Remove `ssm:GetParameters` from source read policy in `iam.tf`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate Terraform/diagnostics for modified files

## Validation Notes

- Confirmed runtime source read path uses `GetParameter`; destination probe uses `GetParameters` after `AssumeRole`.
- Removed unused `ssm:GetParameters` from source read policy in `iam.tf`.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Ran `terraform validate` successfully; existing provider deprecation warnings remain unchanged.
- File diagnostics show no errors for `iam.tf`, `README.md`, and this `tasks.md`.
