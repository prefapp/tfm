# Tasks: Refresh cached destination clients on expired token errors

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add expired-token detection helper in `utils.py`
- [x] 2. Add refresh-and-retry logic in full-sync loop
- [x] 3. Validate diagnostics for changed Python files

## Validation Notes

- Added `is_expired_token_error(exc)` helper in `src/common/utils.py`.
- Updated full-sync loop in `src/handler.py` to clear cached destination clients and retry once on expired-token errors.
- File diagnostics checked for both changed files (no errors).
- `python3 -m py_compile handler.py common/utils.py` executed successfully.
