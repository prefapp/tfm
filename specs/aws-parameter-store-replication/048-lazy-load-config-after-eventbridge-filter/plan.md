# Plan: Lazy-load config after EventBridge no-op filtering

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Move `load_config()` call in `lambda_handler` to after EventBridge no-op short-circuit branch.
2. Keep a single config initialization for remaining paths to avoid behavior drift.
3. Validate Python syntax and diagnostics.
