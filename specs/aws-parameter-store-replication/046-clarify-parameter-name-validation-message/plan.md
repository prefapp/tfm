# Plan: Clarify manual `parameter_name` validation error message

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update `parameter_name` invalid-input response message in `src/handler.py`.
2. Keep validation logic unchanged; message-only fix.
3. Validate syntax/diagnostics.
