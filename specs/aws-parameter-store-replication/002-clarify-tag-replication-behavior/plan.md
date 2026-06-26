# Plan: Clarify tag replication behavior

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Update `docs/header.md` to explain that metadata tags are always applied
2. Regenerate `README.md` with `terraform-docs .` from the module directory
3. Review the rendered docs to ensure the wording matches the actual Lambda behavior
