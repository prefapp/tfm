# Plan: Document async error alarm scope for Lambda invocation modes

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add note in `docs/header.md` under async failure visibility.
2. Clarify that `lambda_async_errors` is for async EventBridge visibility.
3. Mention manual/full-sync caught exceptions may not increase Lambda `Errors` metric.
4. Regenerate README and validate docs files.
