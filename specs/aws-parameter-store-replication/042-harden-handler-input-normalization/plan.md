# Plan: Harden handler input normalization for EventBridge and manual payloads

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add a small helper to normalize/validate parameter names (`str` + trimmed non-empty).
2. Use it in `_extract_parameter_from_eventbridge` and guard event/detail shape before `.get(...)`.
3. Reuse it in manual `parameter_name` validation to keep behavior consistent.
4. Validate diagnostics/syntax for modified file.
