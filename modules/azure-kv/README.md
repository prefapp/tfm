<!-- BEGIN_TF_DOCS -->

# Azure Key Vault Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Key Vault with support for:
- Custom access policies and/or RBAC authorization.
- Integration with Resource Group and tag inheritance.
- Soft delete protection and retention configuration.
- Detailed permissions for keys, secrets, certificates, and storage.

## Main features
- Create Key Vault with advanced security options.
- Support for access policies and RBAC.
- Integration with Azure AD groups, users, and service principals.
- Realistic configuration example.

## Complete usage example

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
  enable_rbac_authorization: false # If RBAC is true, access policies will fail if any are defined.
  access_policies:
    - name: "Name for the Object ID"
      type: "" # Leave empty if you provide the object ID directly
      object_id: "1a9590f4-27d3-4abf-9e30-5be7f46959bb"
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "Group display name"
      type: "group"
      object_id: ""  # Leave empty to look up the group ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "Service Principal display name"
      type: "service_principal"
      object_id: ""  # Leave empty to look up the service principal ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
      certificate_permissions: ["Get", "List"]
      storage_permissions: ["Get", "List"]
    - name: "User principal name"
      type: "user"
      object_id: "" # Leave empty to look up the user ID
      key_permissions: ["Get", "List"]
      secret_permissions: ["Get", "List"]
```

## Notes
- If `enable_rbac_authorization` is true, you must not define access policies.
- You can inherit tags from the resource group with `tags_from_rg`.
- Configure retention and soft delete protection according to your security needs.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
  ├── header.md
  └── footer.md
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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | n/a | <pre>list(object({<br/>    type                    = optional(string)<br/>    name                    = optional(string)<br/>    object_id               = optional(string, "")<br/>    key_permissions         = optional(list(string))<br/>    secret_permissions      = optional(list(string))<br/>    certificate_permissions = optional(list(string))<br/>    storage_permissions     = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | n/a | `bool` | n/a | yes |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | n/a | `bool` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | n/a | `bool` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | n/a | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | n/a | `number` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) - Key Vault with basic access policies and optional RBAC.

## Resources and support

- [Official Azure Key Vault documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Terraform reference for azurerm\_key\_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- [Community support](https://github.com/prefapp/terraform-modules/discussions)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->