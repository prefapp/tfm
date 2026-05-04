# Basic example — `azure-kv`

Creates one Key Vault with **Azure RBAC** enabled and **no access policies**.

Set `resource_group` to an existing resource group and `name` to a **globally unique** vault name (3–24 characters: letters, numbers, and hyphens). This root only configures **`azurerm`** for your subscription; the child module still lists **`azuread`** in its `required_providers` (Terraform installs it), but this RBAC-only path does not evaluate Azure AD data sources. If you extend the stack with access policies using `type` `user`, `group`, or `service_principal`, add **`provider "azuread"`** (and credentials) so those lookups can run.
