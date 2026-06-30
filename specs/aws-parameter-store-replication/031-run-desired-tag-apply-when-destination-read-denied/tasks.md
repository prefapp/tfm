# Tasks: Ensure desired-tag application executes when destination read is denied

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor update-time tag-sync flow in `src/common/replication.py`
- [x] 2. Keep stale-tag pruning skipped on destination-read denial
- [x] 3. Ensure desired-tag apply runs best-effort for all updates
- [x] 4. Validate diagnostics/syntax for modified files

## Validation Notes

- Refactored `src/common/replication.py` so desired-tag application (`add_tags_to_resource`) is no longer nested inside the non-read-denied pruning branch.
- Confirmed stale-tag pruning remains skipped when destination reads are denied.
- Ran `python3 -m py_compile common/replication.py` from module `src/` directory (success).
- Diagnostics checked; unresolved `boto3`/`botocore` imports are pre-existing environment issues.
