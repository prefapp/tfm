# Plan: Ensure desired-tag application executes when destination read is denied

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor update-time tag-sync block in `src/common/replication.py`.
2. Keep stale-tag pruning conditional on destination read availability.
3. Move desired-tag apply block to execute independently for all updates.
4. Validate diagnostics/syntax for changed files.
