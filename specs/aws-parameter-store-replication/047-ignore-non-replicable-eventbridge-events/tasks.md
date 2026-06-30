# Tasks: Ignore non-replicable EventBridge events without falling into manual 400 path

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor `_extract_parameter_from_eventbridge` dispatch semantics
- [x] 2. Update EventBridge branch in `lambda_handler` to ignore non-replicable events
- [x] 3. Validate diagnostics/syntax for modified files

## Validation Notes

- Applied requested semantics in `_extract_parameter_from_eventbridge`:
	- detail-type gate remains the only `(None, False)` path for non-EventBridge payloads.
	- non-dict detail and non-Create/Update operations now return `(None, True)`.
	- extracted name now returns `(parameter_name, True)`.
- Updated `lambda_handler` EventBridge branch to ignore (`return None`) when `is_eventbridge=True` and `parameter_name=None`, avoiding manual-path `400` fallback.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
