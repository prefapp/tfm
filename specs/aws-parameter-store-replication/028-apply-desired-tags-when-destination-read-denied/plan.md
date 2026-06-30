# Plan: Apply desired tags best-effort when destination read is denied

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor update-time tag-sync flow in `src/common/replication.py`.
2. When destination read is denied, skip stale-tag pruning only.
3. Keep desired-tag `AddTagsToResource` call best-effort and independent from pruning path.
4. Validate diagnostics for modified Python file.
