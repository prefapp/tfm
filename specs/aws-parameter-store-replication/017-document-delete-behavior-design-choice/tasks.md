# Tasks: Document delete-event behavior as intentional design choice

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add explicit Create/Update-only note in `docs/header.md`
- [x] 2. Document rationale and stale-parameter consequence
- [x] 3. Regenerate `README.md` via `terraform-docs .`

## Validation Notes

- `docs/header.md` updated with explicit delete-event behavior note.
- `terraform-docs .` executed successfully in module directory (`README.md updated successfully`).
- File-level diagnostics checked for updated docs files.
