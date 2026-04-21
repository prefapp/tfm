<!-- BEGIN_TF_DOCS -->
# `azure-kv`

## Overview

Terraform module that creates an **Azure Key Vault** (`azurerm_key_vault`) in an existing resource group, with optional **access policies** resolved from **Entra ID** (`azuread` data sources for users, groups, and service principals) or **direct `object_id`**, and optional **tag merge** from the resource group.

**Prerequisites**

- Existing **resource group** (`resource_group`).
- Terraform and providers per [`versions.tf`](versions.tf).
- **`azurerm`** and **`azuread`** authentication (e.g. `az login`) when resolving principals by name.
- Permissions to create Key Vaults and assign access policies or RBAC as appropriate for your subscription.

**Behaviour notes (as implemented)**

- **`enable_rbac_authorization`**: when **`true`**, you must **not** combine RBAC with legacy access policies entries in a conflicting way. A **`lifecycle.precondition`** fails if `access_policies` is non-empty while RBAC is enabled (`has_access_policies` in [`main.tf`](main.tf)).
- **`access_policies`**: each entry should have a **unique `name`** (used as `for_each` keys in data sources). Set **`object_id`** to skip lookup; otherwise set **`type`** to `user`, `group`, or `service_principal` and **`name`** to UPN, group display name, or service principal display name respectively.
- **`tags_from_rg`**: when `true`, merge tags from the resource group data source with `tags`.

## Basic usage

```hcl
module "key_vault" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=azure-kv-v1.5.1"

  name                        = "kvexample001"
  resource_group              = "example-rg"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
  enable_rbac_authorization   = false

  access_policies = [
    {
      name                = "bootstrap-admin"
      type                = ""
      object_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      key_permissions     = ["Get", "List"]
      secret_permissions  = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = []
    }
  ]

  tags_from_rg = false
  tags         = { workload = "example" }
}
```

Replace GUIDs and names with real values. With **`enable_rbac_authorization = true`**, use **`access_policies = []`** and manage access via Azure RBAC outside this module.

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Data sources, locals, Key Vault |
| `variables.tf` | Inputs |
| `outputs.tf` | Key Vault resource ID |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Legacy access policies when `enable_rbac_authorization` is false. Each entry needs a unique `name`. Provide `object_id` or set `type` to `user` / `group` / `service_principal` with `name` for lookup. | <pre>list(object({<br/>    type                    = optional(string)<br/>    name                    = optional(string)<br/>    object_id               = optional(string, "")<br/>    key_permissions         = optional(list(string))<br/>    secret_permissions      = optional(list(string))<br/>    certificate_permissions = optional(list(string))<br/>    storage_permissions     = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | When true, use Azure RBAC for data plane access; access policies must be empty (see precondition in main.tf). | `bool` | n/a | yes |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether the vault can be used for Azure Disk Encryption. | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Key Vault (must be globally unique, 3–24 alphanumeric characters). | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled (prevents permanent purge of soft-deleted items). | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group where the Key Vault will be created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the vault (`standard` or `premium`). | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Soft-delete retention period in days for deleted keys, secrets, and certificates. | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Key Vault (merged with resource group tags when `tags_from_rg` is true). | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | When true, merge tags from the resource group with `tags`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the Key Vault. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — Resource group plus Key Vault with one access policy by `object_id`; configure `azurerm` / `azuread` and replace placeholders before plan/apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — Illustrative `values.reference.yaml` for tags, access policies (object ID and Entra lookups), and RBAC notes (see folder README).

## Resources

Terraform **azurerm** docs use **4.21.0** as a baseline aligned with `versions.tf` (`>= 4.21.0`). **azuread** docs use **2.53.0** (`~> 2.53.0`).

- **Azure Key Vault**: [https://learn.microsoft.com/azure/key-vault/general/overview](https://learn.microsoft.com/azure/key-vault/general/overview)
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