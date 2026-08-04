# Tasks: Update AWS provider constraint to v6 for aws-terraform-backend

**Module:** `aws-terraform-backend`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Tasks

- [x] 1. Create `spec.md`, `plan.md`, and `tasks.md` for this change.
- [x] 2. Update `modules/aws-terraform-backend/versions.tf` to require AWS provider `~> 6.40`.
- [x] 3. Fix `modules/aws-terraform-backend/variables.tf` to remove invalid variable default reference (`data.aws_region.current.name`).
- [x] 4. Add `.terraform-docs.yml` and `docs/header.md` + `docs/footer.md` to align with AWS module docs conventions.
- [x] 5. Regenerate `modules/aws-terraform-backend/README.md` using `terraform-docs` (without manual README edits).
- [x] 6. Run formatting/validation checks for the touched module (`terraform fmt -check`, `terraform init -backend=false -upgrade`, `terraform validate`).
- [x] 7. Final review and mark all tasks complete.

**Status:** Complete
