<!-- BEGIN_TF_DOCS -->
# **Azure Key Vault Terraform Module**

## Overview

This module creates an **Azure Key Vault** (`azurerm_key_vault`) in an **existing resource group**. It supports **Azure RBAC** on the vault or **classic access policies**, optional resolution of principals via **Azure AD** data sources (user, group, or service principal by display name or UPN), tag merge from the resource group, and lifecycle **preconditions** so access policies are not mixed with RBAC when that combination is invalid.

The module does **not** create the resource group, private endpoints, or key/secret/certificate resources; consumers add those separately if needed. Use it when you want a small, opinionated wrapper around `azurerm_key_vault` with consistent tagging and access-policy wiring for teams that still use vault access policies or are migrating toward vault-level RBAC.

## Key Features

- **Key Vault**: SKU, soft delete retention, purge protection, disk encryption integration, tenant binding.
- **Authorization model**: `enable_rbac_authorization` toggles between RBAC and access policies; when RBAC is enabled, `access_policies` must be empty.
- **Access policies**: Optional list; object fields remain optional in the type for compatibility. For real policies, use a **non-empty, unique `name`** per row (`main.tf` uses it as a `for_each` key and for Azure AD lookups). Use `type` (`user`, `group`, `service_principal`) plus `name`, or `object_id` with empty `type` for a direct principal.
- **Outputs**: Exposes the Key Vault **`id`** for downstream resources, role assignments, or references that need the Azure resource identifier.

## Prerequisites

- Existing **resource group** (`resource_group`); the module reads it for location and optional tag inheritance.
- **Key Vault name** must be **globally unique**, 3–24 characters, and use only letters, numbers, and hyphens.
- The module depends on **hashicorp/azuread** and **hashicorp/azurerm** (`versions.tf`); Terraform installs the required provider versions. Configure **`provider "azuread"`** with working credentials **only when** access policies use `type` `user`, `group`, or `service_principal` so the lookup data sources can run. For RBAC-only setups or policies that only set `object_id` (empty `type`), those data sources are not instantiated and you do not need Azure AD authentication for this module alone.
- For **access policies** with principal lookup, principals must exist and be resolvable (correct UPN, group display name, or service principal display name).

## Basic Usage

Point `source` at this module and set required inputs. Use **RBAC** (`enable_rbac_authorization = true`) with an empty `access_policies` list for the smallest surface, or **access policies** with `enable_rbac_authorization = false`.

### Example (RBAC on the vault)

```hcl
module "key_vault" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                         = "kv-myapp-dev01"
  resource_group               = "my-resource-group"
  enabled_for_disk_encryption  = false
  soft_delete_retention_days   = 7
  purge_protection_enabled     = false
  sku_name                     = "standard"
  enable_rbac_authorization    = true
  access_policies              = []

  tags_from_rg = false
  tags = {
    environment = "dev"
  }
}
```

Assign **Key Vault data plane** or **management** roles at vault scope or above when using RBAC; this module does not create role assignments.

### Example (access policies, RBAC disabled)

```hcl
module "key_vault_access_policies" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                         = "kv-myapp-legacy01"
  resource_group               = "my-resource-group"
  enabled_for_disk_encryption  = false
  soft_delete_retention_days   = 7
  purge_protection_enabled     = false
  sku_name                     = "standard"
  enable_rbac_authorization    = false

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  access_policies = [
    {
      name                    = "workload-spn"
      type                    = ""
      object_id               = "11111111-1111-1111-1111-111111111111"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
  ]
}
```

Replace `object_id` with a real principal in your tenant. To resolve principals by **UPN / display name** instead, set `type` to `user`, `group`, or `service_principal` and set `name` accordingly; that path uses the Azure AD provider data sources.

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.53.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.53.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.67.0 |

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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Legacy access policies when `enable_rbac_authorization` is false.<br/><br/>Attributes stay **optional** in the object type for backward compatibility with existing callers. When you pass entries, each one should still set a **non-empty, unique `name`**: `main.tf` uses `name` as the `for_each` key and to index Azure AD data sources, so missing or duplicate names typically surface as errors at plan time.<br/><br/>Provide `object_id` (with `type` unset/empty) or set `type` to `user`, `group`, or `service_principal` and use `name` as UPN, group display name, or service principal display name for lookup.<br/><br/>If `type` is empty and `object_id` is empty, the module cannot resolve an object ID and that row is skipped for the vault access policy block (no explicit error). | <pre>list(object({<br/>    type                    = optional(string)<br/>    name                    = optional(string)<br/>    object_id               = optional(string, "")<br/>    key_permissions         = optional(list(string))<br/>    secret_permissions      = optional(list(string))<br/>    certificate_permissions = optional(list(string))<br/>    storage_permissions     = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | When true, use Azure RBAC for data plane access; access policies must be empty (see precondition in main.tf). | `bool` | n/a | yes |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether the vault can be used for Azure Disk Encryption. | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Globally unique name of the Key Vault (3–24 characters; letters, numbers, and hyphens). | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled (prevents permanent purge of soft-deleted vaults and objects when true). | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group where the Key Vault will be created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the vault (`standard` or `premium`). | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Number of days soft-deleted items are retained before permanent deletion. | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Key Vault (merged with resource group tags when `tags_from_rg` is true). | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | When true, merge tags from the resource group with `tags`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Azure resource ID of the Key Vault. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — Key Vault with **RBAC** enabled and no access policies; set an existing resource group and a globally unique vault name (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — Reference HCL and YAML for **access policies** (object ID and Azure AD lookups) and tag options (`values.reference.yaml`; see folder README).

## Resources

Terraform **azurerm** links below use **4.21.0** as a baseline aligned with the minimum `azurerm` version in `versions.tf` (`>= 4.21.0`). **azuread** links use **2.53.0**, aligned with `versions.tf` (`~> 2.53.0`). Pinned versions in your workspace appear in the **Providers** table after regenerating this README with `terraform-docs .`, as described in [README.md generation](https://github.com/prefapp/tfm/blob/main/CONTRIBUTING.md#5-readmemd-generation).

- **Azure Key Vault**: [https://learn.microsoft.com/azure/key-vault/](https://learn.microsoft.com/azure/key-vault/)
- **azurerm\_key\_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/resources/key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/resources/key_vault)
- **azurerm\_client\_config** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/client_config](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/client_config)
- **azurerm\_resource\_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/resource_group)
- **azuread\_user** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user)
- **azuread\_group** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group)
- **azuread\_service\_principal** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->