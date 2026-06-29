# Plan: Refresh cached destination clients on expired token errors

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add `is_expired_token_error` helper in `src/common/utils.py`.
2. Use helper in full-sync loop in `src/handler.py`.
3. On expired-token errors, clear client cache and retry parameter once.
4. Validate diagnostics/syntax for updated Python files.
5. Mark tasks complete.
