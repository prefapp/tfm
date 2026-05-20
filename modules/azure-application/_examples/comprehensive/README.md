# Comprehensive example

Illustrates optional `client_secret` (with `rotation_days` when enabled), `federated_credentials`, and `extra_role_assignments`. Values are placeholders; wire real Key Vault IDs, subscription scopes, and OIDC issuer/subject values before apply.

## Reference values

See [`values.reference.yaml`](./values.reference.yaml) for commented shapes you can adapt in your root module.

## Usage

```bash
terraform init
terraform plan
```

## Configuration

Add a `main.tf` in this folder (or copy patterns into your stack) using the reference YAML as a guide. Keep secrets and tenant-specific IDs out of version control.
