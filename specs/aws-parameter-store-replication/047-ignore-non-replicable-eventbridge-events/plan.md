# Plan: Ignore non-replicable EventBridge events without falling into manual 400 path

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Adjust `_extract_parameter_from_eventbridge` to return `(None, True)` for ignorable Parameter Store Change events.
2. Update EventBridge branch in `lambda_handler` to no-op when `parameter_name` is missing.
3. Validate syntax/diagnostics.
