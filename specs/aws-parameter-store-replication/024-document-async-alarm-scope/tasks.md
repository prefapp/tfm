# Tasks: Document async error alarm scope for Lambda invocation modes

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add async alarm scope note in `docs/header.md`
- [x] 2. Regenerate `README.md` via `terraform-docs .`
- [x] 3. Validate docs files

## Validation Notes

- Added scope note in async visibility section of `docs/header.md` clarifying `lambda_async_errors` alarm intent and manual/full-sync caveat.
- Ran `terraform-docs .` successfully and updated `README.md`.
- File-level diagnostics for `docs/header.md` and `README.md` show no errors.
