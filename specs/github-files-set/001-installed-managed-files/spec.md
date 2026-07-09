# Specification: installed_managed_files accumulator for github-files-set

**Issue:** [prefapp/gitops-k8s#2296](https://github.com/prefapp/gitops-k8s/issues/2296)
**Module:** `modules/github-files-set`

## Problem

When a `FirestartrGithubRepositoryFeature` manages files with `userManaged: true`, Firestartr must seed those files once with default content and then never overwrite them again. Two failure modes exist in the current implementation:

1. **Deletion on feature upgrade** — when a `userManaged: true` file is removed from a feature definition, Terraform sees it in state but not in config and plans a destroy, deleting the user-customised file.

2. **Re-provisioning on every reconciliation** — without a record of which user-managed files have already been seeded, `gh_provisioner` cannot distinguish "new file to seed" from "already-seeded file to skip".

## Goal

Add an `installed_managed_files` input variable to `github-files-set` so that `gh_provisioner` can pass in the accumulated list of already-provisioned user-managed file addresses. The module then computes and outputs the updated list after each apply, allowing the caller to persist it across reconciliations.

The output is the **monotonically-growing union** of previously known addresses and newly provisioned ones, minus any addresses that have transitioned from `userManaged = true` to `userManaged = false` in the current config.

## Scope

- Add `installed_managed_files` input variable (`list(string)`, default `[]`) to `variables.tf`.
- Rename the existing `user_managed_files` output to `installed_managed_files` and update its value to implement the accumulation formula.
- Update `docs/header.md` to document the new variable and output behaviour.
- Update `_examples/basic/files.yaml` to demonstrate the new variable.
- Regenerate `README.md` via `terraform-docs`.

## Out of Scope

- Changes to `gh_provisioner` or other packages (tracked in the upstream issue).
- Changes to `main.tf` resource logic (filtering already happens in `gh_provisioner`).
- Changes to any other module.

## Accumulation Formula

```
installed_managed_files_output =
  distinct(concat(var.installed_managed_files, [addr for f in config.files if f.userManaged]))
  − [addr for f in config.files if !f.userManaged]
```

- **Add**: addresses of files in the current `config.files` with `userManaged = true` (newly provisioned this apply).
- **Keep**: addresses already in `var.installed_managed_files` that do not appear in `config.files` with `userManaged = false`.
- **Remove**: addresses that appear in `config.files` with `userManaged = false` (transitioning back to Terraform-managed).

## Acceptance Criteria

- `variable "installed_managed_files"` present in `variables.tf` with type `list(string)` and default `[]`.
- `output "installed_managed_files"` present in `outputs.tf` implementing the accumulation formula.
- `terraform fmt`, `terraform validate` pass.
- `terraform-docs` regenerates `README.md` correctly.
- `tasks.md` is updated and remains in the repository after merge.
- No `CHANGELOG.md` is touched (handled by Release Please).
