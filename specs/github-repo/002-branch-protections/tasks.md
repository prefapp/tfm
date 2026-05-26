# Tasks: Add support for legacy branch protections (github-repo module)

**Module:** github-repo
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files
- [x] 2. Update `variables.tf` – add optional `branchProtections` field with validation
- [x] 3. Update `main.tf` – add `github_branch_protection` resource
- [x] 4. Update `outputs.tf` – add `branch_protections` output
- [x] 5. Update `docs/header.md` – add branch protections usage example
- [x] 6. Update `docs/footer.md` – add branch protections footer example
- [x] 7. Regenerate `README.md` with `terraform-docs`
- [x] 8. Run `terraform fmt` and `terraform validate`
- [x] 9. Update changelog / version bump note (will be handled by Release Please automation)
- [x] 10. Final review and create PR

**Status:** Complete
