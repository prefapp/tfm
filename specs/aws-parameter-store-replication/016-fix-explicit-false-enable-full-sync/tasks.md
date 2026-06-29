# Tasks: Honor explicit false for full-sync event flags

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Use explicit key checks for `enable_full_sync` / `initial_run`
- [x] 2. Preserve existing normalization behavior
- [x] 3. Validate diagnostics for `src/handler.py`

## Validation Notes

- `src/handler.py` diagnostics: no errors.
- `python3 -m py_compile handler.py`: success.
