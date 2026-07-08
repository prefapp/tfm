# Tasks: installed_managed_files accumulator (gitops-k8s#2296)

**Module:** github-files-set
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files
- [x] 2. Update `variables.tf` — add `installed_managed_files` variable
- [x] 3. Update `outputs.tf` — rename `user_managed_files` → `installed_managed_files` with accumulation formula
- [x] 4. Update `docs/header.md` — document new variable and output behaviour
- [x] 5. Update `_examples/basic/files.yaml` — show `installed_managed_files` usage
- [x] 6. Run `terraform fmt` and `terraform validate`
- [x] 7. Regenerate `README.md` with `terraform-docs .`
- [ ] 8. Changelog will be updated by Release Please automation

**Status:** Complete (pending commit approval)
