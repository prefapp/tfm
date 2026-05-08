# Tasks: Remove deprecated GitHub secret encrypted_value usage (Issue #1256)

**Module:** github-repo-secrets-section
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files.
- [x] 2. Review current `modules/github-repo-secrets-section/` implementation and provider documentation.
- [x] 3. Add conditional public-key data sources for Actions and Dependabot secrets.
- [x] 4. Replace deprecated Actions and Dependabot `encrypted_value` usage with `value_encrypted` plus `key_id`.
- [x] 5. Update module documentation and examples for the preserved config shape, import behavior, and delete behavior.
- [x] 6. Regenerate README.md with `terraform-docs .`.
- [x] 7. Run `terraform fmt`, `terraform init`, and `terraform validate` for the module/example where feasible.
- [x] 8. Final review and ensure changelog remains untouched.

**Status:** Complete

## Validation Notes

- Ran `tofu fmt -recursive .` with OpenTofu v1.10.6 downloaded to a temporary directory because no `terraform` binary was installed.
- Ran `tofu init -backend=false` and `tofu validate` for `modules/github-repo-secrets-section`.
- Ran `tofu init -backend=false` and `tofu validate` for `modules/github-repo-secrets-section/_examples/basic`.
- Regenerated README with `go run github.com/terraform-docs/terraform-docs@latest .` because no `terraform-docs` binary was installed.
