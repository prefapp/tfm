# Tasks: Isolate stale-tag pruning failures from tag-apply path

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Refactor update tag-sync block to isolate pruning failures
- [x] 2. Ensure desired-tag add/update is attempted even when pruning fails
- [x] 3. Validate updated Python file

## Validation Notes

- File-level diagnostics run for `src/common/replication.py`.
- Reported unresolved imports (`boto3`, `botocore`) are environment-related and pre-existing.
