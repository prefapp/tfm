# Comprehensive reference — `azure-mi`

- [`module.reference.hcl`](./module.reference.hcl) — Illustrative module block with **RBAC**, **federated credentials** (GitHub, Kubernetes, OIDC), and optional **Key Vault access policies**.
- [`values.reference.yaml`](./values.reference.yaml) — Keys at the **root** of the file match module variable names (suitable for `yamldecode` + merge into a `module` block or a thin wrapper).

Replace subscription IDs, scopes, vault IDs, and GitHub org/repo with real values before apply. Keep large samples here instead of embedding them in the terraform-docs `README.md` body.
