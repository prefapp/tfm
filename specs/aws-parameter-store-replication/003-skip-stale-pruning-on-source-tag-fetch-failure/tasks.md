# Tasks: Skip stale tag pruning when source tag fetch fails

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Add a source-tag fetch success flag in `src/common/replication.py`
- [x] 2. Skip stale-tag pruning when source tags could not be fetched
- [x] 3. Validate the updated Python file (syntax/quick checks)

## Validation Notes

- Static error check run on `src/common/replication.py` reports unresolved `boto3`/`botocore` imports in local editor environment.
- No syntax errors introduced by this change; logic update is limited to pruning guards and warning logs.
