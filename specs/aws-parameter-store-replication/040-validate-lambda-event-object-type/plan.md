# Plan: Validate Lambda event payload type before dictionary access

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add an early `isinstance(event, dict)` guard in `src/handler.py`.
2. Return structured `400` response for invalid payload types.
3. Keep existing invocation-mode logic unchanged for valid dict payloads.
4. Validate diagnostics/syntax.
