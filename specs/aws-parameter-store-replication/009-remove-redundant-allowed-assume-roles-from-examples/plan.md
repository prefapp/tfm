# Plan: Remove redundant `allowed_assume_roles` from usage examples

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Edit `docs/header.md` basic/cross-account usage examples
2. Regenerate module `README.md` via `terraform-docs .`
3. Verify rendered examples no longer show duplicated `allowed_assume_roles`
