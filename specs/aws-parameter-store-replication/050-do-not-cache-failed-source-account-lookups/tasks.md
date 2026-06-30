# Tasks: Do not cache failed source account STS lookups

- [x] 1. Update `load_config()` to cache only successful source account lookups
- [x] 2. Preserve empty-string fallback for a single failing invocation
- [x] 3. Validate syntax and diagnostics

## Validation Notes

- `load_config()` now assigns `_SOURCE_ACCOUNT_CACHE` only after successful `sts:GetCallerIdentity`.
- On STS failure, the current invocation returns `source_account = ""` without mutating the cache, so later warm invocations can retry.
- Ran `python3 -m py_compile common/config.py` (success).
- Diagnostics only show the pre-existing environment warning for unresolved `boto3` import.
