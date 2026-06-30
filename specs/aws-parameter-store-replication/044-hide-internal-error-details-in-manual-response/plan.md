# Plan: Hide internal exception details from manual invocation HTTP response

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Edit manual invocation exception response block in `src/handler.py`.
2. Remove raw exception field from HTTP body and use a generic message.
3. Keep existing logging of exception details unchanged.
4. Validate syntax/diagnostics.
