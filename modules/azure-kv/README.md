<!-- BEGIN_TF_DOCS -->
# `azure-kv`

## Overview

Terraform module that creates a single **Azure Key Vault** (`azurerm_key_vault`) in an existing resource group. It reads the target resource group and current client tenant, and optionally resolves **Azure AD** principals (user, group, or service principal) to build **access policies** when RBAC for the vault is disabled.

**Prerequisites**

- An Azure resource group that already exists (`resource_group` is its name).
- Appropriate credentials for the `azurerm` and `azuread` providers (for example Azure CLI, environment variables, or Workload Identity in CI).

**Behaviour and limitations (as implemented)**

- **`enable_rbac_authorization`**: When `true`, the vault uses Azure RBAC for data plane access. In that mode you **must** leave `access_policies` empty; otherwise apply fails (see `lifecycle` `precondition` in the module). The module does **not** assign Key Vault RBAC roles for you—manage those outside this module.
- **`access_policies` with `enable_rbac_authorization = false`**: Each entry can supply `object_id` directly, or set `type` to `user`, `group`, or `service_principal` and `name` for lookup via `azuread_*` data sources. Entries whose `object_id` cannot be resolved (for example wrong name) are **skipped** for the dynamic `access_policy` block; the module does not fail the plan for a missing lookup.
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.53.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.53.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Access policy entries when `enable_rbac_authorization` is false. Use a non-empty `object_id` to skip Azure AD lookup,<br/>or set `type` to `user`, `group`, or `service_principal` and `name` for lookup. Entries that do not resolve to an<br/>object id are omitted from the vault access policies. Must be empty when `enable_rbac_authorization` is true. | <pre>list(object({<br/>    type                    = optional(string)<br/>    name                    = optional(string)<br/>    object_id               = optional(string, "")<br/>    key_permissions         = optional(list(string))<br/>    secret_permissions      = optional(list(string))<br/>    certificate_permissions = optional(list(string))<br/>    storage_permissions     = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | If true, use Azure RBAC for data plane access; `access_policies` must then be empty. | `bool` | n/a | yes |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether the Key Vault can be used for Azure Disk Encryption. | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Globally unique name of the Key Vault (Azure naming rules apply). | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled (prevents permanent delete until retention elapses). | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group where the Key Vault is created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the Key Vault (for example `standard` or `premium`). | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Number of days soft-deleted items are retained before permanent deletion. | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Key Vault (merged with resource group tags when `tags_from_rg` is true). | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | When true, merge resource group tags with `tags` (module tags override on key conflict). | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Key Vault. |

## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — minimal `module` block and provider wiring.
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — illustrative `values.reference.yaml` for wrappers or pipelines.

## Provider documentation (pinned to module constraints)

- [azurerm\_key\_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/resources/key_vault)
- [azurerm\_client\_config](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/client_config)
- [azurerm\_resource\_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/resource_group)
- [azuread\_user](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user)
- [azuread\_group](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group)
- [azuread\_service\_principal](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal)

## Issues

Report problems or suggestions in [prefapp/tfm issues](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
