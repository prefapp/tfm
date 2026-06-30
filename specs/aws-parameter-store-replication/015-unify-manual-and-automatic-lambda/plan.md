# Plan: Unify manual and automatic parameter replication into one Lambda

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Create a unified handler that routes by event shape:
   - EventBridge `detail-type=Parameter Store Change` => automatic mode
   - direct invocation with `parameter_name` => manual single parameter
   - direct invocation with `initial_run` (or `enable_full_sync`) => full sync
2. Replace dual Lambda module blocks with one Terraform Lambda module block.
3. Replace dual IAM roles/policies with one role/policy set (conditionally include `ssm:DescribeParameters` based on `enable_full_sync`).
4. Keep or deprecate legacy outputs (`lambda_manual_*`, `lambda_automatic_*`) mapping to unified resources for compatibility.
5. Update docs/examples/README via `terraform-docs .`.
6. Validate formatting/diagnostics and task completion.
