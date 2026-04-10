# Basic example — `azure-flexible-server-postgresql`

Minimal `module` block with **public** network access and one firewall rule. Run `terraform init` and `terraform validate` locally; configure `azurerm` authentication and replace names with real resources before `terraform apply`.

The Key Vault secret named in `administrator_password_key_vault_secret_name` must be writable by your deployment identity (the module seeds it from `random_password` on first apply).
