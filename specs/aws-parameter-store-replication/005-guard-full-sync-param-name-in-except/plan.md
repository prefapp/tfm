# Plan: Guard full-sync exception logging against missing parameter name

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update full-sync `except` log call to use a safe fallback from `param_meta`
2. Validate updated handler for errors
3. Mark tasks completed
