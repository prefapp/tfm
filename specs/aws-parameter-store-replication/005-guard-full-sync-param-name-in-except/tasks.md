# Tasks: Guard full-sync exception logging against missing parameter name

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update full-sync exception logging to avoid unbound `param_name`
- [x] 2. Validate updated Python file

## Validation Notes

- File-level diagnostics run on `src/lambda_manual_replication/handler.py`.
- Reported unresolved imports are environment-related and pre-existing for this Lambda package layout.
