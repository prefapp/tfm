<!-- BEGIN_TF_DOCS -->
# Azure Key Vault (`azure-kv`)

## Overview

Creates one **Key Vault** (`azurerm_key_vault`) in an existing resource group. You choose either **Azure RBAC** for the data plane (`enable_rbac_authorization = true`) or **classic access policies** (`enable_rbac_authorization = false`).

When RBAC is enabled, **`access_policies` must be empty**; otherwise the module fails with a lifecycle precondition.

## Tags

If **`tags_from_rg`** is `true`, tags are **`merge(resource_group.tags, var.tags)`** (values in `var.tags` win on duplicate keys). If `false`, only **`var.tags`** are applied.

## Access policies (RBAC disabled)

Each entry uses **`name`** as the internal map key (keep names unique).

- Non-empty **`object_id`**: that ID is applied to the Key Vault access policy (preferred for known object IDs).
- Empty **`object_id`**: set **`type`** to **`user`**, **`group`**, or **`service_principal`** (matched **case-sensitively** in code) and **`name`** for UPN / display name lookup via `azuread_*` data sources.

If both **`object_id`** and a lookup **`type`** are set, **`object_id`** is used for the policy, but Terraform may still evaluate the Azure AD data source for that `type`; avoid mixing unless you understand that behaviour.

## Prerequisites

- Existing **resource group**.
- **azurerm** and **azuread** providers configured (data sources need appropriate directory read permissions when resolving principals).

## Basic usage

```hcl
module "kv" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                        = "examplekv001"
  resource_group              = "example-rg"
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = false

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  access_policies = [
    {
      name                    = "bootstrap-principal"
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = []
      storage_permissions     = []
    }
  ]
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Access-policy entries when enable\_rbac\_authorization is false.<br/>Each entry uses `name` as the internal key. If `object_id` is non-empty, it is used for the policy; otherwise `type` must be `user`, `group`, or `service_principal` and `name` is resolved via Azure AD data sources. | <pre>list(object({<br/>    type                    = optional(string)<br/>    name                    = optional(string)<br/>    object_id               = optional(string, "")<br/>    key_permissions         = optional(list(string))<br/>    secret_permissions      = optional(list(string))<br/>    certificate_permissions = optional(list(string))<br/>    storage_permissions     = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Use Azure RBAC for data plane; when true, access\_policies must be empty (enforced by precondition). | `bool` | n/a | yes |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether Azure Disk Encryption can retrieve secrets from this vault. | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Key Vault name (globally unique, 3–24 alphanumeric characters). | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Enable purge protection (irreversible once enabled). | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group for the Key Vault. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU: standard or premium. | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Soft-delete retention in days (see provider documentation for allowed values). | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the Key Vault; merged with resource group tags when tags\_from\_rg is true. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | If true, merge tags from the resource group with var.tags (var.tags override on key conflicts). | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Key Vault. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — Key Vault with access policies (`main.tf` + `values.yaml`).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — **`values.reference.yaml`**: illustrative inputs (RBAC vs policies, tags).

## Remote resources

- **Microsoft Learn — Key Vault**: [https://learn.microsoft.com/azure/key-vault/](https://learn.microsoft.com/azure/key-vault/)
- **Terraform `azurerm_key_vault`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/latest](https://registry.terraform.io/providers/hashicorp/azuread/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->