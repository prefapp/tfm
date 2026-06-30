# Tasks: Rename destination assume-role inline policy to match its actual purpose

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Rename STS assume policy resource and generated name in `iam.tf`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics/terraform for modified files

## Validation Notes

- Renamed the inline IAM policy resource in `iam.tf` from `lambda_ssm_write_destinations` to `lambda_sts_assume_destinations`.
- Renamed the generated policy name suffix from `ssm-write-destinations` to `sts-assume-destinations`.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Ran `terraform validate` successfully; existing provider deprecation warnings remain unchanged.
- File diagnostics show no errors for `iam.tf`, `README.md`, and this `tasks.md`.
