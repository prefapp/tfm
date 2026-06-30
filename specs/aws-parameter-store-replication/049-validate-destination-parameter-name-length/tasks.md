# Tasks: Validate destination parameter name length after regional prefixing

- [x] 1. Refactor `_build_destination_parameter_name` return flow to use `dest_name`
- [x] 2. Add post-prefix 2048-char validation and explicit error
- [x] 3. Validate syntax/diagnostics

## Validation Notes

- Applied requested substitutions in `_build_destination_parameter_name`:
	- compute `dest_name` in both path/non-path branches
	- validate `len(dest_name) > 2048` and raise `ValueError` with explicit message
	- return `dest_name`
- Ran `python3 -m py_compile common/replication.py` (success).
- Diagnostics: only pre-existing environment import-resolution warnings (`boto3`, `botocore`).
