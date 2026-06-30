# Tasks: Return 404 for manual ParameterNotFound

- [x] 1. Add parameter-not-found exception helper in `handler.py`
- [x] 2. Return 404 in manual path for not-found failures
- [x] 3. Keep 500 path for other failures
- [x] 4. Validate syntax and diagnostics

## Validation Notes

- Added `_is_parameter_not_found_error(exc)` helper in `src/handler.py`.
- Manual replication exception path now returns HTTP 404 when the error is `ParameterNotFound`.
- Non-not-found failures keep the existing HTTP 500 behavior.
- Ran `python3 -m py_compile handler.py` (success).
- Diagnostics only report pre-existing environment warning for unresolved `boto3` import.
