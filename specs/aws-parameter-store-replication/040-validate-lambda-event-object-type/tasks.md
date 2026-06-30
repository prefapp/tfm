# Tasks: Validate Lambda event payload type before dictionary access

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add early event type guard in `src/handler.py`
- [x] 2. Return `400` for non-object payloads
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Added an early `isinstance(event, dict)` guard in `src/handler.py` before any `.get(...)` usage.
- Non-object payloads now return `400` with message: `Invalid invocation: event payload must be a JSON object.`
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
