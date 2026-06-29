# Plan: Unify Lambda source packaging strategy

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Remove duplicate `src/common` entry from `source_path` in `lambda.tf`.
2. Update imports in `src/handler.py` to `common.*` modules.
3. Update imports in `src/common/replication.py` to `common.*` modules.
4. Validate Terraform + Python syntax.
5. Mark tasks complete.
