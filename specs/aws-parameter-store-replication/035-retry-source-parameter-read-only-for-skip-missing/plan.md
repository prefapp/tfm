# Plan: Retry source parameter reads only for skip-missing flows

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor `_get_parameter_value_with_retry()` in `src/common/replication.py` to fail fast on `ParameterNotFound` when `skip_missing = false`.
2. Preserve the current retry loop and final skip behavior when `skip_missing = true`.
3. Validate diagnostics and Python syntax for the modified file.
