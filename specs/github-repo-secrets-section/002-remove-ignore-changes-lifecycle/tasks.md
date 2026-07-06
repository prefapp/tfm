# Tasks: Replace ignore_changes with deterministic secret update trigger (Issue #1282)

**Module:** github-repo-secrets-section
**Spec:** spec.md
**Plan:** plan.md

## Tasks

- [x] 1. Create this specs folder and initial spec/plan/tasks files.
- [x] 2. Review current `modules/github-repo-secrets-section/` implementation.
- [x] 3. Add `actions_sha256`, `codespaces_sha256`, `dependabot_sha256` optional map inputs to `var.config`.
- [x] 4. Add input validations for SHA256 maps (key matching + hex format).
- [x] 5. Add `terraform_data` trigger resources for each secret group.
- [x] 6. Wire `replace_triggered_by` in secret resource lifecycles; keep `ignore_changes` (sha256 input uses `try()` defaulting to `null` → stable when absent, meaningful hash when present).
- [x] 7. Update `docs/header.md` and `_examples/` for the new sha256 input pattern and fallback behavior.
- [x] 8. Regenerate README.md with `terraform-docs .`.
- [x] 9. Run `tofu fmt`, `tofu init`, `tofu validate` for both module and example.
- [x] 10. Final review — ensure no CHANGELOG.md was touched.

**Status:** Complete

## Validation Notes

- `tofu fmt -recursive modules/github-repo-secrets-section/` passed.
- `tofu init -backend=false && tofu validate` passed for both the module and the `_examples/basic` example.
- `terraform-docs .` regenerated `README.md` successfully.
- No `CHANGELOG.md` files were touched.
- Generated `.terraform/` directories and lock files were cleaned up after validation.
