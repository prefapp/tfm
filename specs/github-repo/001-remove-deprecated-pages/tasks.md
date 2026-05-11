# Tasks: Remove deprecated pages section (Issue #1255)

**Module:** github-repo  
**Spec:** spec.md  
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files
- [x] 2. Review current `pages` implementation in `modules/github-repo/`
- [x] 3. Refactor `main.tf` – remove `pages` block from `github_repository` and add `github_repository_pages` resource
- [x] 4. Update `variables.tf` – handle deprecation/removal of `pages` variable
- [x] 5. Update `outputs.tf` if needed
- [x] 6. Update README.md and examples
- [x] 7. Run `terraform validate` and existing tests
- [ ] 8. Update changelog / version bump note (will be handled by Release Please automation)
- [x] 9. Final review and create PR

**Status:** Complete
