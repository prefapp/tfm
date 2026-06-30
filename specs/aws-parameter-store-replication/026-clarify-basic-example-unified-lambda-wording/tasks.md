# Tasks: Clarify basic example wording for unified Lambda and optional EventBridge

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update wording in `_examples/basic/README.md`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics for modified files

## Validation Notes

- Updated `_examples/basic/README.md` bullets under "What it creates" to describe the unified Lambda and optional EventBridge trigger.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Diagnostics show no errors in `_examples/basic/README.md`, `README.md`, and this `tasks.md`.
