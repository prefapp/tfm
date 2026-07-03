# Specification: Replace ignore_changes with deterministic secret update trigger

**Issue:** [#1282](https://github.com/prefapp/tfm/issues/1282)
**Module:** `modules/github-repo-secrets-section`

### Problem

The module sets `ignore_changes = [key_id, value_encrypted]` on `github_actions_secret` and `github_dependabot_secret`, and `ignore_changes = [encrypted_value]` on `github_codespaces_secret`. This prevents Terraform from updating existing secrets when their values change — the lifecycle block silently ignores any modifications to the secret content.

Simply removing `ignore_changes` would cause Terraform to detect a diff on every plan because the libsodium ciphertext (`value_encrypted` / `encrypted_value`) is non-deterministic — it changes each time even if the plaintext is identical. Every apply would send a redundant write to the GH API.

### Goal

Allow secret updates to be applied when the plaintext value actually changes, while suppressing spurious diffs from the non-deterministic ciphertext.

### Solution

Use the `terraform_data` + `replace_triggered_by` pattern:

```hcl
resource "terraform_data" "secret_trigger" {
  for_each = var.config.actions
  input    = var.config.actions_sha256[each.key]  # deterministic SHA256 of plaintext
}

resource "github_actions_secret" "this" {
  for_each = var.config.actions

  repository      = data.github_repository.this.name
  secret_name     = each.key
  key_id          = one(data.github_actions_public_key.this[*].key_id)
  value_encrypted = each.value

  lifecycle {
    replace_triggered_by = [terraform_data.secret_trigger[each.key]]
    ignore_changes       = [key_id, value_encrypted]  # suppress spurious ciphertext diff
  }
}
```

When the plaintext value changes, the caller computes a new SHA256, which changes the `terraform_data.secret_trigger.input`. This triggers replacement of the `github_actions_secret`. The `ignore_changes` stays to suppress the non-deterministic ciphertext diff on every plan.

### Scope

- Add `actions_sha256`, `codespaces_sha256`, `dependabot_sha256` optional map inputs to `var.config`.
- Add `terraform_data.secret_trigger` resources for each secret group (Actions, Codespaces, Dependabot).
- Wire `replace_triggered_by` to the corresponding trigger resource in each secret resource's lifecycle.
- Keep `ignore_changes = [encrypted_value]` on Codespaces and `ignore_changes = [key_id, value_encrypted]` on Actions/Dependabot — they are still needed for the non-deterministic ciphertext.
- Update documentation and examples.
- Regenerate README.

### Input Contract Changes

```
# Current
actions    = optional(map(string), {})
codespaces = optional(map(string), {})
dependabot = optional(map(string), {})

# New (additive, non-breaking)
actions    = optional(map(string), {})
codespaces = optional(map(string), {})
dependabot = optional(map(string), {})

actions_sha256    = optional(map(string), {})
codespaces_sha256 = optional(map(string), {})
dependabot_sha256 = optional(map(string), {})
```

The SHA256 maps are optional. When absent/empty, the trigger input stays `null` (stable) and `ignore_changes` continues to suppress ciphertext diffs — no behavioral change from the pre-fix module. This ensures full backward compatibility. Callers that supply SHA256 hashes unlock deterministic update detection.

### Input Contract

The SHA256 maps are optional. When absent/empty, `terraform_data` input defaults to `null` (stable) via `try()`, so no replacement is ever triggered — the secret lifecycle behaves as before the fix. When provided with matching keys, the SHA256 digest drives `replace_triggered_by`.

This avoids conditional resource blocks and keeps the lifecycle uniform across all configurations.

### Validation

- SHA256 map keys must be a subset of their corresponding secret map keys (extraneous keys in SHA256 maps are caught).
- SHA256 values must match the 64-char hex pattern `^[a-f0-9]{64}$`.

### Out of Scope

- Renaming or restructuring outputs.
- Any `CHANGELOG.md` edits — Release Please owns changelog updates.

### Acceptance Criteria

- When SHA256 maps are provided, `terraform_data` + `replace_triggered_by` are wired and a plaintext change triggers a secret replacement.
- When SHA256 maps are absent, the trigger input defaults to `null` (stable) and `ignore_changes` remains — full backward compatibility.
- `terraform init` and `terraform validate` pass for the module and example.
- `terraform fmt` passes.
- README is regenerated via `terraform-docs .` and reflects the change.
- `tasks.md` is updated and included in the PR.
