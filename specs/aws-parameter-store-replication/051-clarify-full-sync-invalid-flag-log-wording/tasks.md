# Tasks: Clarify full-sync invalid flag warning wording

- [x] 1. Update warning text to cover invalid type and invalid value
- [x] 2. Validate syntax/diagnostics

## Validation Notes

- Updated warning text in `src/handler.py` to: "Invalid full sync flag type or value in invocation payload".
- Behavior remains unchanged; only log wording was clarified.
- Ran `python3 -m py_compile handler.py` (success).
- Diagnostics show only pre-existing environment warning for unresolved `boto3` import.
