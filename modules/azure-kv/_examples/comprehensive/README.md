# Comprehensive reference — `azure-kv`

- [`module.reference.hcl`](./module.reference.hcl) — Illustrative module block with **access policies** (direct `object_id` and Azure AD lookups by type/name).
- [`values.reference.yaml`](./values.reference.yaml) — Same inputs as YAML for `yamldecode` or external tooling.

These samples are documentation-oriented: replace names, IDs, and resource group with values valid in your tenant before apply. Each `access_policies` entry needs a **distinct, non-empty `name`** (the module uses it as an internal map key). Keep large samples here instead of embedding them in the terraform-docs `README.md` body.
