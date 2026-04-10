# Basic example — `azure-kv`

Wires the module with fictional values so you can run `terraform init` and `terraform validate` locally.

Before `terraform apply`, set:

- `resource_group` to an existing resource group.
- `name` to a **globally unique** Key Vault name.
- `access_policies` to real `object_id` values and permission sets, or use `type` + `name` for Azure AD lookup.

Configure authentication for `azurerm` and `azuread` (for example `az login`).
