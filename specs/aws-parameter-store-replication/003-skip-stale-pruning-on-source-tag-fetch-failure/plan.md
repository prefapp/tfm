# Plan: Skip stale tag pruning when source tag fetch fails

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update `src/common/replication.py` to record source-tag fetch success
2. Gate stale-tag pruning on both `enable_tag_replication` and successful source-tag fetch
3. Keep metadata-tag add/update behavior unchanged
4. Validate the updated Python file for syntax/runtime regressions
