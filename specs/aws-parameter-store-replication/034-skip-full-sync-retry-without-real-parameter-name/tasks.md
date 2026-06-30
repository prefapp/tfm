# Tasks: Skip expired-token retry when full-sync item lacks a real parameter name

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Guard expired-token retry in `src/handler.py` with real parameter-name presence
- [x] 2. Add logging for skipped retry without valid parameter context
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Updated `src/handler.py` to distinguish a retry-safe real parameter name from fallback placeholder labels in full-sync exception handling.
- Expired-token retry now runs only when a real non-empty parameter name is available; otherwise a skip warning is logged.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
