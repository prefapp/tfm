# Plan: Clarify `allowed_assume_roles` semantics

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update the variable description in `variables.tf`
2. Regenerate module docs with `terraform-docs .`
3. Verify the generated README input row matches the new wording
