# Basic example — `azure-kv`

Creates one Key Vault with **Azure RBAC** enabled and **no access policies**.

Set `resource_group` to an existing resource group and `name` to a **globally unique** vault name (3–24 characters: letters, numbers, and hyphens). Configure the **`azurerm`** provider for your subscription. This module also declares **`azuread`** in `required_providers`; include `provider "azuread" {}` in the example root so `terraform init` succeeds (no Azure AD lookups run for this RBAC-only configuration).
