# Comprehensive reference — `azure-kv`

- [`module.reference.hcl`](./module.reference.hcl) — Illustrative module block with **access policies** (direct `object_id` and Azure AD lookups by type/name).
- [`values.reference.yaml`](./values.reference.yaml) — Same inputs as YAML for `yamldecode` or external tooling.

These samples are documentation-oriented: replace names, IDs, and resource group with values valid in your tenant before apply. The variable type keeps `name` optional for compatibility, but each sample row uses a **distinct, non-empty `name`** because `main.tf` keys lookups by `name`. Keep large samples here instead of embedding them in the terraform-docs `README.md` body.
