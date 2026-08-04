# Comprehensive reference — `azure-mi`

- [`module.reference.hcl`](./module.reference.hcl) — Illustrative module block with **RBAC**, **federated credentials** (GitHub, Kubernetes, OIDC), and optional **Key Vault access policies**.
- [`values.reference.yaml`](./values.reference.yaml) — Illustrative values for most module inputs (same key names as the module variables).

It is **not** consumed by Terraform automatically. Typical uses:

- Copy fragments into `.tfvars` or HCL `module` arguments.
- Or load with `yamldecode(file(...))` in a root module and **map each field** to the `azure-mi` module arguments (Terraform does not support splatting a map directly into a `module` block).

Replace subscription IDs, scopes, vault IDs, and GitHub org/repo with real values before apply.

**Convention:** keep large YAML samples in `_examples/**` instead of embedding them in the terraform-docs `README.md` body.
