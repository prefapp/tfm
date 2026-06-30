# Tasks: Harden handler input normalization for EventBridge and manual payloads

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add shared parameter-name normalization helper in `src/handler.py`
- [x] 2. Harden EventBridge extraction and detail-shape guards
- [x] 3. Reuse helper for manual `parameter_name` validation
- [x] 4. Validate diagnostics/syntax for modified files

## Validation Notes

- Added `_normalize_parameter_name(...)` to centralize `str` + trim + non-empty validation.
- `_extract_parameter_from_eventbridge(...)` now guards `event` and `detail` shape before `.get(...)`, and only treats normalized non-empty string names as valid.
- Manual `parameter_name` path now reuses the same normalization helper and keeps `400` responses for invalid values.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
