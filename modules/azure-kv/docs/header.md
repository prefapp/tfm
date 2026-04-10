# `azure-kv`

## Overview

Terraform module that creates a single **Azure Key Vault** (`azurerm_key_vault`) in an existing resource group. It reads the target resource group and current client tenant, and optionally resolves **Azure AD** principals (user, group, or service principal) to build **access policies** when RBAC for the vault is disabled.

**Prerequisites**

- An Azure resource group that already exists (`resource_group` is its name).
- Appropriate credentials for the `azurerm` and `azuread` providers (for example Azure CLI, environment variables, or Workload Identity in CI).

**Behaviour and limitations (as implemented)**

- **`enable_rbac_authorization`**: When `true`, the vault uses Azure RBAC for data plane access. In that mode you **must** leave `access_policies` empty; otherwise apply fails (see `lifecycle` `precondition` in the module). The module does **not** assign Key Vault RBAC roles for you—manage those outside this module.
- **`access_policies` with `enable_rbac_authorization = false`**: Each entry can supply `object_id` directly, or set `type` to `user`, `group`, or `service_principal` and `name` for lookup via `azuread_*` data sources. Entries that provide `object_id` directly do not require Azure AD lookup. Entries that use `type` + `name` depend on those `azuread_*` data sources resolving successfully; if the referenced principal cannot be found (for example because the name is wrong), Terraform plan/apply fails rather than silently skipping that entry.
- **`tags_from_rg`**: When `true`, tags on the resource group are merged with `tags` (values in `tags` override on key collision).

## Basic usage

```hcl
module "key_vault" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=azure-kv-v1.5.1"

  name                        = "example-kv-name"
  resource_group              = "example-rg"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = false

  access_policies = [
    {
      name               = "ContosoReaders"
      type               = "group"
      object_id          = ""
      key_permissions    = ["Get", "List"]
      secret_permissions = ["Get", "List"]
    }
  ]

  tags_from_rg = true
  tags         = { example = "basic" }
}
```

The Key Vault is created in the same **location** as the existing resource group (no separate `location` input).

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Key Vault resource, data sources, locals |
| `variables.tf` | Input variables |
| `outputs.tf` | Exported values |
| `versions.tf` | Terraform and provider version constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Human-written overview (this file) |
| `docs/footer.md` | Examples and external links |
| `_examples/basic` | Minimal runnable-style example |
| `_examples/comprehensive` | Reference YAML for integration tools |
| `README.md` | Generated API tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
