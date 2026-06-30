# Plan: Guard role ARN validation with map/object decode check

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update `variables.tf` role ARN validation condition to `can(tomap(jsondecode(var.destinations_json))) && alltrue([...])`.
2. Keep regex semantics unchanged.
3. Regenerate docs with `terraform-docs .`.
4. Run `terraform validate` and diagnostics.
