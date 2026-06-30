# Plan: Validate manual `parameter_name` input before replication

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add early manual-input validation logic in `src/handler.py` for `parameter_name`.
2. Return `400` when `parameter_name` is present but not a non-empty string.
3. Trim valid `parameter_name` values before replication.
4. Validate diagnostics/syntax for modified files.
