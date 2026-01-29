<!-- BEGIN_TF_DOCS -->
# Azure Custom Role Terraform Module

## Overview

This Terraform module allows you to create a custom role in Azure, specifying actions, data actions, and the assignable scopes.

## Main features
- Create custom roles in Azure.
- Flexible definition of actions, data actions, not actions, and not data actions.
- Support for multiple assignable scopes.

## Ejemplo completo

Puedes encontrar un ejemplo completo en [`_examples/basic/values.yaml`](../\_examples/basic/values.yaml).

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes) | One or more assignable scopes for this Role Definition. The first one will become de scope at which the Role Definition applies to. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Role Definition | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A permissions block with possible 'actions', 'data\_actions', 'not\_actions' and/or 'not\_data\_actions'. | <pre>object({<br/>    actions          = optional(list(string), [])<br/>    data_actions     = optional(list(string), [])<br/>    not_actions      = optional(list(string), [])<br/>    not_data_actions = optional(list(string), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | # OUTPUTS SECTION Role Definition Id |

---

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples/basic) - Basic custom role definition with assignable scopes and permissions.

## Additional resources

- [Azure Custom Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Terraform AzureRM Provider - azurerm\_role\_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition)
- [Official Terraform documentation](https://www.terraform.io/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->