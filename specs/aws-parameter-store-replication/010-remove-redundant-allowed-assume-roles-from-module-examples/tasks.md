# Tasks: Remove redundant `allowed_assume_roles` from module examples

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Clean `_examples/basic/main.tf`
- [x] 2. Clean `_examples/existing_resources/main.tf`
- [x] 3. Regenerate module `README.md` with `terraform-docs .`
- [x] 4. Validate updated example files

## Validation Notes

- File-level diagnostics checked for both example files after edit.
- `terraform-docs .` executed successfully in `modules/aws-parameter-store-replication` (`README.md updated successfully`).
