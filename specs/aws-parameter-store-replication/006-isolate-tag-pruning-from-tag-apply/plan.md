# Plan: Isolate stale-tag pruning failures from tag-apply path

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Split tag sync exception handling in `src/common/replication.py`
2. Keep pruning conditions unchanged and independent from add/update path
3. Validate the Python file for syntax/editor diagnostics
4. Mark tasks complete
