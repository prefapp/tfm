# Plan: Document delete-event behavior as intentional design choice

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add an explicit note in `docs/header.md` about Create/Update-only replication.
2. Mention rationale (safer DR posture) and consequence (stale destination parameters).
3. Regenerate module `README.md` with `terraform-docs .`.
4. Mark tasks complete.
