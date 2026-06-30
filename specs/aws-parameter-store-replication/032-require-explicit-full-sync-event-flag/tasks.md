# Tasks: Require explicit event flag to run full sync

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor full-sync request resolution in `src/handler.py`
- [x] 2. Keep config as guardrail only for requested full sync
- [x] 3. Update no-valid-invocation messaging for explicit full-sync requests
- [x] 4. Validate diagnostics/syntax for modified files

## Validation Notes

- Updated `src/handler.py` so full sync is only requested when event includes `enable_full_sync` or `initial_run`; absent keys no longer fall back to `config.enable_full_sync`.
- Preserved config guardrail behavior: requested full sync still returns 403 when module config does not allow it.
- Updated invalid-invocation warning/message to require explicit full-sync request.
- Ran `python3 -m py_compile handler.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3` import is a pre-existing environment issue.
