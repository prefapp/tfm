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
- [ ] 6. Run `terraform fmt` and `terraform validate` (requires local terraform binary — skipped)
- [ ] 7. Final review and create PR

**Status:** In Progress (code changes complete, pending final review)
