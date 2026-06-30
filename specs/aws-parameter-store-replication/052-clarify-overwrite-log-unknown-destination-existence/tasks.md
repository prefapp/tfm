# Tasks: Clarify overwrite log when destination existence is unknown

- [x] 1. Add distinct log message for overwrite-with-unknown-existence path
- [x] 2. Keep behavior unchanged for known create/update paths
- [x] 3. Validate syntax and diagnostics

## Validation Notes

- Updated pre-`put_parameter` logging in `src/common/replication.py`:
	- `destination_read_denied=True` now logs: "Overwriting destination parameter with unknown prior existence (read denied)".
	- Known-existence update/create log branches remain unchanged.
- Replication behavior and API call flow were not modified.
- Ran `python3 -m py_compile common/replication.py` (success).
- Diagnostics only show pre-existing unresolved environment imports (`boto3`, `botocore`).
