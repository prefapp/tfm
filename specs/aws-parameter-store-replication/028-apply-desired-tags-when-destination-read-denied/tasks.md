# Tasks: Apply desired tags best-effort when destination read is denied

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update read-denied tag-sync control flow in `src/common/replication.py`
- [x] 2. Keep stale-tag pruning skipped when destination reads are denied
- [x] 3. Preserve best-effort desired-tag application path
- [x] 4. Validate diagnostics for modified files

## Validation Notes

- Updated `src/common/replication.py` read-denied update path to skip only stale-tag pruning while preserving desired-tag application via `AddTagsToResource` as best effort.
- Updated logging to explicitly state pruning is skipped due to read denial and desired tags are still attempted.
- Diagnostics checked for modified files; unresolved imports for `boto3`/`botocore` are pre-existing environment issues.
