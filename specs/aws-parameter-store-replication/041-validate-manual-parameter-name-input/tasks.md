# Tasks: Validate manual `parameter_name` input before replication

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add `parameter_name` validation in `src/handler.py`
- [x] 2. Return `400` for invalid manual payload values
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Added early `parameter_name` validation in `src/handler.py` when the key is present in the event payload.
- Non-string and whitespace-only `parameter_name` values now return `400` with a clear message.
- Valid string values are trimmed before manual replication.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
