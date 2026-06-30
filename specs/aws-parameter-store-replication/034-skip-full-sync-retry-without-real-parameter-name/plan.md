# Plan: Skip expired-token retry when full-sync item lacks a real parameter name

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor full-sync exception handling in `src/handler.py` to distinguish real parameter names from placeholders.
2. Retry after credential refresh only when a valid parameter name exists.
3. Add clear logging when retry is skipped due to missing parameter-name context.
4. Validate diagnostics and Python syntax.
