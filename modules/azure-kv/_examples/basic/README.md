# Basic example — `azure-kv`

Creates one Key Vault with **Azure RBAC** enabled and **no access policies**.

Set `resource_group` to an existing resource group and `name` to a **globally unique** vault name (3–24 letters and numbers). Configure the `azurerm` and `azuread` providers (subscription and authentication) before `terraform apply`.
