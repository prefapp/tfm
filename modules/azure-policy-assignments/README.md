<!-- BEGIN_TF_DOCS -->
# Azure Policy assignments Terraform module (`azure-policy-assignments`)

## Overview

This module creates **Azure Policy assignments** at one of four **scopes**, driven by the **`scope`** field on each item in **`assignments`**:

| `scope` value (string) | Resource |
|------------------------|----------|
| `resource` | `azurerm_resource_policy_assignment` |
| `resource group` | `azurerm_resource_group_policy_assignment` |
| `subscription` | `azurerm_subscription_policy_assignment` (current subscription from provider) |
| `management group` | `azurerm_management_group_policy_assignment` |

Policy definition resolution uses **`policy_definition_id`** when set; otherwise **`policy_name`** is resolved via **`azurerm_policy_definition`** (by display name). Optional **`parameters`** are passed as a map and **JSON-encoded** for the assignment resource.

An empty **`assignments`** list (`[]`, default) creates nothing.

## Key features

- **Built-in vs custom**: `policy_type` is `builtin` or `custom` (validated); default `builtin`.
- **Outputs**: separate lists of assignment IDs per scope type.

## Prerequisites

- **azurerm** provider configured; permissions to assign policies at the chosen scopes.
- For **`policy_name`** lookup, a matching policy definition must exist in the tenant.

## Basic usage

```hcl
module "policy_assignments" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-policy-assignments?ref=<version>"

  assignments = [
    {
      name          = "audit-locations-sub"
      policy_type   = "builtin"
      policy_name   = "Allowed locations"
      scope         = "subscription"
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_management_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignments"></a> [assignments](#input\_assignments) | Policy assignments to create; empty list creates no resources. Use `scope` to pick assignment type (see module README). | <pre>list(object({<br/>    name                  = string<br/>    policy_type           = optional(string, "builtin")<br/>    policy_name           = optional(string)<br/>    policy_definition_id  = optional(string)<br/>    resource_id           = optional(string)<br/>    resource_group_id     = optional(string)<br/>    management_group_id   = optional(string)<br/>    resource_group_name   = optional(string)<br/>    management_group_name = optional(string)<br/>    scope                 = string<br/>    description           = optional(string)<br/>    display_name          = optional(string)<br/>    enforce               = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/>    location = optional(string)<br/>    metadata = optional(string)<br/>    non_compliance_message = optional(list(object({<br/>      content                        = string<br/>      policy_definition_reference_id = optional(string)<br/>    })))<br/>    not_scopes = optional(list(string))<br/>    parameters = optional(map(any))<br/>    overrides = optional(list(object({<br/>      value = string<br/>      selectors = optional(list(object({<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      })))<br/>    })))<br/>    resource_selectors = optional(list(object({<br/>      name = optional(string)<br/>      selectors = list(object({<br/>        kind   = string<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_policy_assignment_ids"></a> [management\_group\_policy\_assignment\_ids](#output\_management\_group\_policy\_assignment\_ids) | List of all Azure management group policy assignment IDs |
| <a name="output_resource_group_policy_assignment_ids"></a> [resource\_group\_policy\_assignment\_ids](#output\_resource\_group\_policy\_assignment\_ids) | List of all Azure resource group policy assignment IDs |
| <a name="output_resource_policy_assignment_ids"></a> [resource\_policy\_assignment\_ids](#output\_resource\_policy\_assignment\_ids) | List of all Azure resource policy assignment IDs |
| <a name="output_subscription_policy_assignment_ids"></a> [subscription\_policy\_assignment\_ids](#output\_subscription\_policy\_assignment\_ids) | List of all Azure subscription policy assignment IDs |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/basic) — Single subscription-scope assignment (illustrative).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/comprehensive) — **`values.reference.yaml`**: multiple scopes (replace IDs and names for your tenant).

## Remote resources

- **Azure Policy assignments**: [https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure](https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure)
- **Terraform assignment resources** (subscription, RG, resource, management group): [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->