# Tasks: Clarify required destination SSM actions when tag replication is disabled

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update permission wording in `docs/header.md`
- [x] 2. Regenerate `README.md` via `terraform-docs .`
- [x] 3. Validate diagnostics for modified files

## Validation Notes

- Updated `docs/header.md` to clarify that when `enable_tag_replication = false`, only `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource` are optional, while `ssm:PutParameter`, `ssm:GetParameters`, and `ssm:AddTagsToResource` remain required.
- Ran `terraform-docs .` successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
- Diagnostics check reports no errors for `docs/header.md`, `README.md`, and this `tasks.md`.
