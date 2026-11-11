<!-- BEGIN_TF_DOCS -->
# **Azure Cognitive Services Account Terraform Module**

## Overview

This module creates and manages one Azure Cognitive Services account using
`azurerm_cognitive_account`. It supports Azure OpenAI accounts and other account kinds
supported by the AzureRM provider. The target resource group must already exist. Model
deployments are separate resources and are not created by this module.

The module exposes the account endpoint, resource ID, name, custom subdomain, and tags.
It configures public network access and account network ACLs, with optional IP and
virtual network rules. Tags can be supplied directly or merged with the resource
group's existing tags.

## Key features

- **One account per module instance**: clear Terraform state ownership for a single account.
- **Azure OpenAI support**: defaults the account kind to `OpenAI` and exposes its endpoint.
- **Network ACLs**: supports allow/deny defaults, IP rules, subnet rules, and trusted-service bypass.
- **Tag inheritance**: optionally merges resource group tags with module tags; module values take precedence.
- **Model deployment separation**: model name, version, and capacity are outside this module.

## Prerequisites

- The resource group must exist before applying this module.
- The AzureRM provider identity needs permission to manage Cognitive Services accounts and, when enabled, read the resource group for tag inheritance.
- The account name and custom subdomain must be available in Azure.

## Examples

Each example directory contains exactly two files: `example.tf` for the Terraform
module call and `example.yaml` showing the equivalent values in YAML. The **basic**
example uses public access and direct tags. The **restricted** example uses a
default-deny ACL, a subnet rule, and inherited resource group tags.

The subnet in a virtual network rule must have the Microsoft Cognitive Services
service endpoint enabled. A default-deny ACL only allows matching configured rules.

## Import and lifecycle

The AzureRM provider supports importing this resource by its full Azure resource ID:

```text
/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.CognitiveServices/accounts/<account-name>
```

The resource address inside this module is `azurerm_cognitive_account.this` (for a module call named `cognitive_account`, the root address is `module.cognitive_account.azurerm_cognitive_account.this`). Destroying the module deletes the Cognitive Services account and can make dependent model deployments or data inaccessible. Before replacing an existing inline claim with this module, migrate the existing state to the module resource address or import the existing account; do not apply with an empty state against an account already in Azure.

The AzureRM provider attempts to purge the account during deletion. Review the provider's `features.cognitive_account.purge_soft_delete_on_destroy` setting before enabling destroy workflows, especially when soft-delete recovery is required.

## File structure

```
.
├── data.tf
├── locals.tf
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs/
└── _examples/
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.66.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.66.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Unique custom subdomain used to construct the account endpoint. Changing this may force replacement. | `string` | n/a | yes |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Whether to enable dynamic throttling. Leave null for OpenAI and AIServices accounts, where the provider does not allow this argument. | `bool` | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Kind of Cognitive Services account. Use OpenAI for Azure OpenAI accounts. | `string` | `"OpenAI"` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether key-based local authentication is enabled. Disable when using Microsoft Entra ID authentication only. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the account will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cognitive Services account. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network access rules for the account. Set default\_action to Deny and use IP or virtual network rules to restrict access. | <pre>object({<br/>    bypass         = string<br/>    default_action = string<br/>    ip_rules       = optional(list(string), [])<br/>    virtual_network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br/>    })), [])<br/>  })</pre> | n/a | yes |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access from the account is restricted. | `bool` | `false` | no |
| <a name="input_project_management_enabled"></a> [project\_management\_enabled](#input\_project\_management\_enabled) | Enable project management features on the account. | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the account is reachable through its public endpoint. Set false when using private endpoints. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group for the account. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the account, for example S0. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the account. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Whether to merge tags from the resource group with the tags supplied to this module. Module tags take precedence. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognitive_account_id"></a> [cognitive\_account\_id](#output\_cognitive\_account\_id) | Azure resource ID of the Cognitive Services account. |
| <a name="output_cognitive_account_name"></a> [cognitive\_account\_name](#output\_cognitive\_account\_name) | Name of the Cognitive Services account. |
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | Custom subdomain name assigned to the account. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint URL of the Cognitive Services account. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the account. |

## Examples

For detailed usage, refer to the module examples:

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-cognitive-account/_examples/basic) — `example.tf` and equivalent `example.yaml` for public access and direct tags.
- [restricted](https://github.com/prefapp/tfm/tree/main/modules/azure-cognitive-account/_examples/restricted) — `example.tf` and equivalent `example.yaml` for a default-deny ACL, subnet rule, and inherited resource-group tags.

## Resources

- **Azure Cognitive Services account**: [https://learn.microsoft.com/azure/ai-services/](https://learn.microsoft.com/azure/ai-services/)
- **Terraform `azurerm_cognitive_account`**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0/docs/resources/cognitive_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0/docs/resources/cognitive_account)
- **Terraform `azurerm_resource_group` data source**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0/docs/data-sources/resource_group)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.66.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->