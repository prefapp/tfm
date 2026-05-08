# Specification: Remove deprecated GitHub secret encrypted_value usage

**Issue:** [#1256](https://github.com/prefapp/tfm/issues/1256)
**Module:** `modules/github-repo-secrets-section`

### Problem

The GitHub provider now marks `encrypted_value` as deprecated for `github_actions_secret` and `github_dependabot_secret`. The module still assigns pre-encrypted secret values through that deprecated argument, so Terraform and OpenTofu emit deprecation warnings during plan/apply.

### Goal

Update the module to use the provider-supported replacement argument for affected secret resources while preserving the existing `config` object contract used by GitHub Automated Provisioning Systems such as `ghaps`.

### Scope

- Add public-key data source lookups needed by provider replacement arguments.
- Update `github_actions_secret` and `github_dependabot_secret` to use `value_encrypted` with the matching key ID.
- Keep `github_codespaces_secret` on `encrypted_value` because the current provider documentation does not mark that argument deprecated.
- Preserve the existing input shape: map values remain pre-encrypted secret values.
- Update documentation and examples where they describe provider arguments, import behavior, or delete behavior.
- Regenerate README documentation.

### Out of Scope

- Renaming `config.actions`, `config.codespaces`, or `config.dependabot`.
- Switching to plaintext secret inputs.
- Changing secret rotation semantics beyond replacing the deprecated provider arguments.
- Editing any `CHANGELOG.md`; Release Please owns changelog updates.

### Acceptance Criteria

- `github_actions_secret` no longer uses deprecated `encrypted_value`.
- `github_dependabot_secret` no longer uses deprecated `encrypted_value`.
- Existing `config` shape remains compatible with generated `terraform.tfvars.json`.
- Documentation explains the pre-encrypted input contract and import/delete behavior.
- `terraform fmt`, `terraform init`, `terraform validate`, and `terraform-docs .` are run where feasible.
- `tasks.md` is updated and included in the PR.
