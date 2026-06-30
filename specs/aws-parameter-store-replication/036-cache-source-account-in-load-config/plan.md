# Plan: Cache source account lookup in Lambda execution environment

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Introduce a module-level cache for `source_account` in `src/common/config.py`.
2. Reuse the cached value inside `load_config()` and perform STS lookup only when cache is empty.
3. Preserve current exception fallback to `""`.
4. Validate diagnostics and Python syntax.
