# Implementation Plan: Replace ignore_changes with deterministic secret update trigger

**Reference:** spec.md + issue #1282

### High-level steps

1. Review current `modules/github-repo-secrets-section/main.tf` lifecycle blocks and `variables.tf`.
2. Add `actions_sha256`, `codespaces_sha256`, `dependabot_sha256` optional `map(string)` inputs to `var.config` object type.
3. Add validations: SHA256 maps must match their corresponding secret map keys; values must match `^[a-f0-9]{64}$`.
4. Add `terraform_data` trigger resources for each secret group (for_each over the corresponding secret map; `input = try(<group>_sha256[each.key], null)`):
   - `terraform_data.actions_trigger`
   - `terraform_data.codespaces_trigger`
   - `terraform_data.dependabot_trigger`
5. Update each secret resource lifecycle:
   - If sha256 map exists for the group: add `replace_triggered_by` pointing to the trigger resource, keep `ignore_changes`.
   - If sha256 map is absent/empty: remove `ignore_changes` entirely (fallback).
6. Update `docs/header.md` and `_examples/` to describe the new sha256 input pattern and the fallback behavior.
7. Regenerate README.md with `terraform-docs .`.
8. Run `terraform fmt`, `terraform init`, `terraform validate`.

### Technical notes

- `terraform_data` resources require `for_each` over the sha256 map (same keys as the secret map). The trigger input is the SHA256 hex string.
- `replace_triggered_by` references `terraform_data.<trigger>[each.key]`. When the SHA256 changes, Terraform replaces the secret resource.
- Since the trigger has the same keys as the secret resource, the `for_each` loops align perfectly.
- For the fallback path (no sha256 provided), the behavior matches the original issue — `ignore_changes` is simply removed, accepting a diff on every plan but enabling updates.
- No state manipulation is required; existing resources will see an updated lifecycle in the next plan.
