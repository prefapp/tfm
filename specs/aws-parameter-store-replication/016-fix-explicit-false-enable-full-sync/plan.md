# Plan: Honor explicit false for full-sync event flags

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Replace `or`-based event flag extraction with explicit key checks.
2. Keep normalization logic for bool/string/other types.
3. Validate diagnostics for `src/handler.py`.
4. Mark tasks complete.
