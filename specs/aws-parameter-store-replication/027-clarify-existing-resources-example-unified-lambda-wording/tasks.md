# Tasks: Clarify existing_resources example wording for unified Lambda behavior

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Align wording in `_examples/existing_resources/README.md`
- [x] 2. Regenerate module `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics for modified files

## Validation Notes

- `_examples/existing_resources/README.md` now uses unified Lambda wording in "What it creates".
- Executed `terraform-docs .` in `modules/aws-parameter-store-replication` successfully (`README.md updated successfully`).
- Diagnostics report no errors for `_examples/existing_resources/README.md`, `README.md`, and this `tasks.md`.
