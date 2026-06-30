# Tasks: Retry source parameter reads only for skip-missing flows

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor `_get_parameter_value_with_retry()` in `src/common/replication.py`
- [x] 2. Preserve EventBridge/full-sync retry behavior for `skip_missing = true`
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Updated `_get_parameter_value_with_retry()` to use `max_attempts = 3 if skip_missing else 1`, so manual invocation (`skip_missing = false`) fails fast without retry delay or warning noise.
- Preserved existing retry-and-skip behavior when `skip_missing = true`.
- Ran `python3 -m py_compile common/replication.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3`/`botocore` imports are pre-existing environment issues.
