# Tasks: Unify Lambda source packaging strategy

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Use only `src` in Lambda `source_path`
- [x] 2. Update imports to explicit `common.*` paths
- [x] 3. Validate Terraform and Python syntax

## Validation Notes

- Updated `lambda.tf` `source_path` to only include `${path.module}/src`.
- Updated imports in `src/handler.py` and `src/common/replication.py` to explicit `common.*` module paths.
- `terraform validate`: success (existing provider deprecation warnings unchanged).
- `python3 -m py_compile handler.py common/config.py common/utils.py common/replication.py`: success.
