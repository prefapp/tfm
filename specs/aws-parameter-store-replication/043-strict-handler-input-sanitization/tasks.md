# Tasks: Enforce strict handler input sanitization for manual invocations

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add strict validation helpers in `src/handler.py`
- [x] 2. Enforce strict `parameter_name` and full-sync string validation
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Added strict helpers in `src/handler.py`:
	- `_normalize_parameter_name(...)` now rejects non-string, empty/whitespace, whitespace-containing, and >2048-char names.
	- `_parse_full_sync_flag(...)` now accepts bool and strict string tokens only.
- Full-sync string flags now reject unknown tokens with a `400` response instead of silently coercing them to `False`.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
