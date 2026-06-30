# Plan: Align destination existence probe with tag-sync permissions

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Switch destination existence probe to `ssm:GetParameters` in `src/common/replication.py`.
2. Preserve overwrite-mode fallback when destination read is denied.
3. Document required destination IAM actions in `docs/header.md`.
4. Regenerate `README.md` using `terraform-docs .`.
5. Validate updated files and mark tasks complete.
