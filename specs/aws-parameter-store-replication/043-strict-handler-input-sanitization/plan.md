# Plan: Enforce strict handler input sanitization for manual invocations

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add helper(s) in `src/handler.py` for strict parameter-name validation and strict boolean-string parsing.
2. Apply stricter `parameter_name` checks in manual invocation path.
3. Reject unsupported full-sync string values with `400` instead of silently interpreting them.
4. Validate syntax/diagnostics for modified file.
