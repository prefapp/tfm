# Plan: Clarify required destination SSM actions when tag replication is disabled

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Replace the inaccurate sentence in `docs/header.md` under "Important Note: Permissions".
2. Use precise wording that keeps `PutParameter`, `GetParameters`, and `AddTagsToResource` as required when `enable_tag_replication = false`.
3. Regenerate module `README.md` via `terraform-docs .`.
4. Validate modified files for diagnostics.
