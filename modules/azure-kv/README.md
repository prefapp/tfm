## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.21.0 |
| <a name="provider_azurerm"></a> [azuread](#provider\_azuread) | ~> 2.53.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user) | data source |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group) | data source |
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Specifies whether the Key Vault is enabled for Azure Disk Encryption | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Key Vault | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) |  Specifies whether purge protection is enabled for the Key Vault | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group in which the Key Vault is created | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Key Vault (e.g., standard or premium) | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that soft-deleted items are retained in the Key Vault | `number` | n/a | yes |
| <a name="input_enable_rbac_authorization"></a> [enable_rbac_authorization](#input\_enable\_rbac\_authorization) | Set RBAC authorization for the Key Vault. Disable access policies authorization | `bool` | n/a | yes |
| <a name="input_accesss_policies"></a> [access_policies](#input\_access\_policies) | Block for access policies definition. Will fail if `enable_rbac_authorization: true` | `list(object)` | n/a | optional |
| <a name="input_accesss_policies.name"></a> [access_policies.name](#input\_access\_policies.name) | Name for the access policy. Display name in groups and SPN, user principal name in users and custom for `object_id` | `string` | n/a | optional |
| <a name="input_accesss_policies.name.type"></a> [access_policies.name.type](#input\_access\_policies.name.type) | Entity type \[ group \| service_principal \| user \]. If we provide the `object_id` type value must be `""` | `string` | n/a | optional |
| <a name="input_accesss_policies.name.object_id"></a> [access_policies.name.object_id](#input\_access\_policies.name.object_id) | Object ID of the entity. If we provide an entity type value must be `""` | `string` | n/a | optional |
| <a name="input_accesss_policies.name.key_permissions"></a> [access_policies.name.key_permissions](#input\_access\_policies.name.key_permissions) | [List of key permissions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#key_permissions) | `list(string)` | n/a | optional |
| <a name="input_accesss_policies.name.secret_permissions"></a> [access_policies.name.secret_permissions](#input\_access\_policies.name.secret_permissions) | [List of secret permissions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#secret_permissions) | `list(string)` | n/a | optional |
| <a name="input_accesss_policies.name.certificate_permissions"></a> [access_policies.name.certificate_permissions](#input\_access\_policies.name.certificate_permissions) | [List of certificate permissions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#certificate_permissions) | `list(string)` | n/a | optional |
| <a name="input_accesss_policies.name.storage_permissions"></a> [access_policies.name.storage_permissions](#input\_access\_policies.name.storage_permissions) | [List of storage permissions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#storage_permissions) | `list(string)` | n/a | optional |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Enable inherit tags from resource group | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |

## Example

```yaml
# kv.yaml
    values:
      name: "keyvault_name"
      tags_from_rg: true
      tags:
        extra_tags: "example"
      enabled_for_disk_encryption: true
      resource_group: "resource_group_name"
      soft_delete_retention_days: 7
      purge_protection_enabled: true
      sku_name: "standard"
      enable_rbac_authorization: false # If RBAC is set to true access policies will fail if there are any defined.
      access_policies:
      - name: "Name for the Object ID"
        type: "" # Leave empty value if you provide directly the object ID
        object_id: "1a9590f4-27d3-4abf-9e30-5be7f46959bb"
        key_permissions: ["Get", "List"]
        secret_permissions: ["Get", "List"]
        certificate_permissions: ["Get", "List"]
        storage_permissions: ["Get", "List"]
      - name: "Group display name"
        type: "group"
        object_id: ""  # Leave empty value if you want to look up the group ID
        key_permissions: ["Get", "List"]
        secret_permissions: ["Get", "List"]
        certificate_permissions: ["Get", "List"]
        storage_permissions: ["Get", "List"]
      - name: "Service Principal display name"
        type: "service_principal"
        object_id: ""  # Leave empty value if you want to look up the service principal ID
        key_permissions: ["Get", "List"]
        secret_permissions: ["Get", "List"]
        certificate_permissions: ["Get", "List"]
        storage_permissions: ["Get", "List"]
      - name: "User principal name"
        type: "user"
        object_id: "" # Leave empty value if you want to look up the user ID
        key_permissions: ["Get", "List"]
        secret_permissions: ["Get", "List"]
        certificate_permissions: ["Get", "List"]
        storage_permissions: ["Get", "List"]

```
