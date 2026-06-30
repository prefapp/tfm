# Tasks: Inline manual ParameterNotFound detection in handler

- [x] 1. Apply inline `ParameterNotFound` check in manual exception block
- [x] 2. Remove unused helper and keep behavior unchanged
- [x] 3. Validate syntax and diagnostics

## Validation Notes

- Replaced helper usage with inline error-code extraction in manual `except` block:
	- `error_code = (((getattr(e, "response", None) or {}).get("Error") or {}).get("Code"))`
	- 404 is returned when `error_code == "ParameterNotFound"`.
- Removed now-unused `_is_parameter_not_found_error` helper.
- Ran `python3 -m py_compile handler.py` (success).
- Diagnostics only show pre-existing unresolved `boto3` environment warning.
