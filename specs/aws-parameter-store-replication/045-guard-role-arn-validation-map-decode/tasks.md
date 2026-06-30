# Tasks: Guard role ARN validation with map/object decode check

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Restore map/object guard in role ARN validation condition
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate Terraform/diagnostics for modified files

## Validation Notes

- Restored defensive guard in `variables.tf` role ARN validation:
	`can(tomap(jsondecode(var.destinations_json))) && alltrue([...])`.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- `terraform validate` initially failed because modules were not installed after cleanup; ran `terraform init` and then `terraform validate` successfully.
- Validation success includes existing provider deprecation warnings unchanged.
- File diagnostics show no errors for `variables.tf`, `README.md`, and this `tasks.md`.
