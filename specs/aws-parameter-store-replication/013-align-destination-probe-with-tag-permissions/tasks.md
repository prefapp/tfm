# Tasks: Align destination existence probe with tag-sync permissions

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Replace destination existence probe with `GetParameters`
- [x] 2. Keep overwrite fallback on destination read denial
- [x] 3. Document destination IAM actions needed for tag replication
- [x] 4. Regenerate module `README.md` with `terraform-docs .`
- [x] 5. Validate diagnostics for modified files

## Validation Notes

- `terraform-docs .` executed successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- File-level diagnostics checked for modified files.
- `replication.py` reports unresolved imports (`boto3`, `botocore`) as pre-existing environment issues.
