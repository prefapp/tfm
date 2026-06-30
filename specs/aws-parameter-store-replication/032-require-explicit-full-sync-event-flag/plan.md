# Plan: Require explicit event flag to run full sync

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Refactor full-sync flag resolution in `src/handler.py` to remove fallback to `config.enable_full_sync` when no event flag is present.
2. Keep explicit key checks and normalization for `enable_full_sync`/`initial_run` values.
3. Retain config guardrail (`403`) when full sync is requested but not enabled in module config.
4. Update invalid-invocation message to mention explicit full-sync request requirement.
5. Validate diagnostics/syntax for modified file.
