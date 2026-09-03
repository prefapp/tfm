# Deterministic trigger for GitHub secret updates

In `github-repo-secrets-section`, secret resources (`github_actions_secret`, `github_dependabot_secret`, `github_codespaces_secret`) update via a `terraform_data` resource keyed on a caller-supplied SHA256 of the plaintext, wired through `replace_triggered_by`, while keeping `ignore_changes` on the encrypted value argument.

This looks contradictory — `ignore_changes` on the ciphertext next to a trigger that forces replacement — so it is recorded here. The libsodium ciphertext (`value_encrypted` / `encrypted_value`) is **non-deterministic**: it changes on every plan even when the plaintext is identical. Without `ignore_changes` every apply would send a redundant write to the GitHub API; with only `ignore_changes` real value changes would be silently dropped. The SHA256-of-plaintext `terraform_data` input is deterministic, so `replace_triggered_by` fires exactly when the plaintext actually changes.

The trade-off: callers must supply the `*_sha256` maps. Removing this pattern reintroduces either spurious diffs or un-appliable secret updates.

_Harvested from the retired `specs/github-repo-secrets-section/002-remove-ignore-changes-lifecycle`._
