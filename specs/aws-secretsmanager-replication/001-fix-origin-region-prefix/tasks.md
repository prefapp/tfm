# Tasks: Fix origin-region naming semantics in aws-secretsmanager-replication

**Module:** `aws-secretsmanager-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Tasks

- [x] 1. Create `spec.md`, `plan.md`, and `tasks.md` for this change.
- [x] 2. Update replication code to use source region in prefixed destination secret names.
- [x] 3. Update replication tags so `origin-region` is the source region.
- [x] 4. Update module docs text for `add_region_prefix_to_name` and cross-region behavior.
- [x] 5. Regenerate `README.md` using `terraform-docs` (without manual README edits).
- [x] 6. Run targeted validation checks and complete final review.

## Validation Notes

- `terraform-docs .` executed successfully in module directory.
- `terraform fmt -check variables.tf` passed for the touched Terraform file.
- Full-module `terraform fmt -check` reports `lambda.tf` as not formatted (pre-existing, unrelated to this change).
