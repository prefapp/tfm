# Plan: Fix origin-region naming semantics in aws-secretsmanager-replication

**Spec:** `spec.md`
**Module:** `modules/aws-secretsmanager-replication`

## Steps

1. Update replication code so prefixed destination names use source region instead of destination region.
2. Update replication metadata tag `origin-region` to use source region.
3. Update docs in `docs/header.md` and variable description to describe source-region prefix behavior.
4. Regenerate `README.md` with `terraform-docs .` from module directory.
5. Run focused validation checks for modified code/docs and finalize tasks.
