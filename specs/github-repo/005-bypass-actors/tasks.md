# Tasks: Add bypass actors support to branch protections (github-repo module)

**Module:** github-repo
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files
- [x] 2. Update `variables.tf` — add `bypassPullRequestAllowances` field with validations
- [x] 3. Update `main.tf` — add locals, data sources, and `pull_request_bypassers` wiring
- [x] 4. Update `docs/header.md` — add bypass actors usage example
- [x] 5. Regenerate `README.md` with `terraform-docs`
- [x] 6. Add `restrict_pushes.push_allowances` block reusing the same resolved actors
- [ ] 7. Update spec/plan/tasks to document the push allowances behavior
- [ ] 8. Run `terraform fmt` (requires local terraform binary — skipped)
- [ ] 9. Final review and create PR

**Status:** In Progress (code changes complete, pending final review)
