# Tasks: Add bypass actors support to branch protections (github-repo module)

**Module:** github-repo
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files
- [x] 2. Update `variables.tf` — add `bypassPullRequestAllowances` and `pushAllowances` fields with validations
- [x] 3. Update `main.tf` — add locals (collecting from both fields), data sources, and separate wiring for `pull_request_bypassers` and `push_allowances`
- [x] 4. Fix `required_approving_review_count` to default to 1 when `bypassPullRequestAllowances` is set without explicit review count
- [x] 5. Update `docs/header.md` — show both fields independently
- [x] 6. Create `_examples/bypass-actors/main.tf` — standalone example
- [x] 7. Update `docs/footer.md` — add Resources section and link to examples
- [x] 8. Update spec/plan/tasks to reflect the decoupled design
- [x] 9. Regenerate `README.md` with `terraform-docs`
- [ ] 10. Run `terraform fmt`
- [ ] 11. Final review and create PR

**Status:** Code changes complete, pending final review.
