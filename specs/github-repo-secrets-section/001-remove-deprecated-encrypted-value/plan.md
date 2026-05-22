# Implementation Plan: Remove deprecated GitHub secret encrypted_value usage

**Reference:** spec.md + issue #1256

### High-level steps

1. Review the current repository secret module implementation and provider documentation.
2. Add conditional Actions and Dependabot public-key data sources so key IDs are available only when those secret groups are managed.
3. Replace deprecated `encrypted_value` on Actions and Dependabot secret resources with `value_encrypted` and `key_id`.
4. Keep Codespaces unchanged unless provider documentation also marks its argument deprecated.
5. Update module docs and examples to describe the preserved config shape, provider argument mapping, import behavior, and delete behavior.
6. Regenerate README.md with terraform-docs.
7. Run Terraform formatting and validation commands.

### Technical notes

- `github_actions_secret.value_encrypted` and `github_dependabot_secret.value_encrypted` require `key_id`.
- The module already expects callers to provide libsodium-encrypted ciphertext values, so no plaintext secret values should be introduced.
- `ignore_changes` should continue to ignore the managed secret value argument to preserve current lifecycle behavior and import workaround semantics.
- `github_codespaces_secret.encrypted_value` remains in use because current provider documentation does not deprecate it.
