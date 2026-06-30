# Tasks: Fix ineffective destinations role ARN format validation

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Fix `role_arn` validation condition in `variables.tf`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate Terraform/diagnostics for modified files

## Validation Notes

- Replaced ineffective `can(alltrue([...]))` with `can(tomap(jsondecode(var.destinations_json))) && alltrue([...])` so the validation enforces that all destination role ARNs match the expected IAM role ARN format.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Ran `terraform validate` successfully; existing provider deprecation warnings remain unchanged.
- File diagnostics show no errors for `variables.tf`, `README.md`, and this `tasks.md`.
