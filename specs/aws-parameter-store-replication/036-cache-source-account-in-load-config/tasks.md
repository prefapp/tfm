# Tasks: Cache source account lookup in Lambda execution environment

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add module-level cache for source account in `src/common/config.py`
- [x] 2. Reuse cached source account in `load_config()`
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Added module-level `_SOURCE_ACCOUNT_CACHE` in `src/common/config.py`.
- `load_config()` now performs STS `GetCallerIdentity` only when the cache is empty, then reuses the cached value for warm invocations.
- Preserved the existing fallback to `""` when STS lookup fails.
- Ran `python3 -m py_compile common/config.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
