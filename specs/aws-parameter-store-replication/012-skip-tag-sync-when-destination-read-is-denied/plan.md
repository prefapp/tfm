# Plan: Skip destination tag sync when destination read is denied

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Track destination read-denied state from existence probe in `src/common/replication.py`.
2. Short-circuit update-time tag sync when read-denied is true.
3. Add a single explicit warning log for the skip condition.
4. Validate diagnostics for updated Python file.
5. Mark tasks complete.
