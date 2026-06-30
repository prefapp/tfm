# Plan: Reject invalid manual full-sync flag types

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor full-sync flag parsing in `src/handler.py` to reject unsupported value types.
2. Preserve current behavior for booleans and string values.
3. Return a `400` response with clear message for invalid full-sync flag types.
4. Validate diagnostics and Python syntax.
