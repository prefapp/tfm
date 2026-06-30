# Tasks: Reject invalid manual full-sync flag types

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor full-sync flag parsing in `src/handler.py`
- [x] 2. Return `400` for invalid full-sync flag payload types
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Updated `src/handler.py` to accept only boolean and string values for `enable_full_sync` / `initial_run`.
- Unsupported payload types now return `400` with a clear validation message instead of being coerced with `bool(...)`.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
