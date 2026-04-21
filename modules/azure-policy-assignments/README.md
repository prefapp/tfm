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

Policy definition resolution: resources use **`coalesce(policy_definition_id, data lookup)`**. The **`azurerm_policy_definition`** data source runs only when **`policy_name` is non-null** and **`policy_definition_id` is omitted or `null`** (not an empty string `""`—use `null` or omit the attribute so the lookup by display name runs). Assignments that pass only an ID do not trigger that data source. Optional **`parameters`** are a map and are **JSON-encoded** for the assignment resource.

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

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/basic) — One subscription-scoped assignment using a built-in policy display name (configure `azurerm` and validate the policy exists — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/comprehensive) — Illustrative `assignments` across several scopes (`values.reference.yaml`; replace IDs — see folder README).

## Resources

Terraform resource docs use **4.22.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.22.0`).

- **Azure Policy — assignment structure**: [https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure](https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure)
- **azurerm\_subscription\_policy\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/subscription_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/subscription_policy_assignment)
- **azurerm\_resource\_group\_policy\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_group_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_group_policy_assignment)
- **azurerm\_resource\_policy\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_policy_assignment)
- **azurerm\_management\_group\_policy\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/management_group_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/management_group_policy_assignment)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->