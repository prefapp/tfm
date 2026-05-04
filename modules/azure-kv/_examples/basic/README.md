# Basic example — `azure-kv`

Creates one Key Vault with **Azure RBAC** enabled and **no access policies**.

Set `resource_group` to an existing resource group and `name` to a **globally unique** vault name (3–24 characters: letters, numbers, and hyphens). Configure the **`azurerm`** provider for your subscription. The module declares **`azuread`** in `required_providers`; Terraform resolves provider packages automatically—this RBAC-only stack does not evaluate Azure AD data sources. If you add access policies with `type` set to `user`, `group`, or `service_principal`, configure the **Azure AD** provider so those lookups can authenticate.
