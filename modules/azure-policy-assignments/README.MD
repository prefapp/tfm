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
| <a name="input_assignments"></a> [assignments](#input\_assignments) | List of objects containing all the variables for the policy assignments. | <pre>list(object({<br/>    name                  = string<br/>    policy_type           = optional(string, "builtin")<br/>    policy_name           = optional(string)<br/>    policy_definition_id  = optional(string)<br/>    resource_id           = optional(string)<br/>    resource_group_id     = optional(string)<br/>    management_group_id   = optional(string)<br/>    resource_group_name   = optional(string)<br/>    management_group_name = optional(string)<br/>    scope                 = string<br/>    description           = optional(string)<br/>    display_name          = optional(string)<br/>    enforce               = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/>    location = optional(string)<br/>    metadata = optional(string)<br/>    non_compliance_message = optional(list(object({<br/>      content                        = string<br/>      policy_definition_reference_id = optional(string)<br/>    })))<br/>    not_scopes = optional(list(string))<br/>    parameters = optional(string)<br/>    overrides = optional(list(object({<br/>      value = string<br/>      selectors = optional(list(object({<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      })))<br/>    })))<br/>    resource_selectors = optional(list(object({<br/>      name = optional(string)<br/>      selectors = list(object({<br/>        kind   = string<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_policy_assignment_ids"></a> [management\_group\_policy\_assignment\_ids](#output\_management\_group\_policy\_assignment\_ids) | List of all Azure management group policy assignment IDs |
| <a name="output_resource_group_policy_assignment_ids"></a> [resource\_group\_policy\_assignment\_ids](#output\_resource\_group\_policy\_assignment\_ids) | List of all Azure resource group policy assignment IDs |
| <a name="output_resource_policy_assignment_ids"></a> [resource\_policy\_assignment\_ids](#output\_resource\_policy\_assignment\_ids) | List of all Azure resource policy assignment IDs |
| <a name="output_subscription_policy_assignment_ids"></a> [subscription\_policy\_assignment\_ids](#output\_subscription\_policy\_assignment\_ids) | List of all Azure subscription policy assignment IDs |

## Example Usage YAML

```yaml
    values:
      assignments:
        - name: "example-assignment-3"
          policy_type: "custom"
          policy_name: "Example Policy"
          resource_id: "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test/providers/Microsoft.KeyVault/vaults/test"
          scope: "resource"

        - name: "example-assignment-2"
          policy_type: "builtin"
          policy_name: "Allowed virtual machine size SKUs"
          resource_group_id: "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test"
          scope: "resource group"

        - name: "example-assignment-2"
          policy_type: "builtin"
          policy_name: "Allowed virtual machine size SKUs"
          resource_group_name: "test"
          scope: "resource group"

        - name: "example-assignment-1"
          policy_type: "builtin"
          policy_name: "Allowed locations"
          scope: "subscription"

        - name: "example-assignment-4"
          policy_type: "custom"
          policy_name: "Example Policy"
          management_group_name: "example"
          scope: "management group"
```
## Example usage HCL

```hcl
assignments = [
  {
    name                  = "example-assignment-3"
    policy_type           = "custom"
    policy_name           = "Example Policy"
    resource_id           = "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test/providers/Microsoft.KeyVault/vaults/-test"
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "resource"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-2"
    policy_type           = "builtin"
    policy_name           = "Allowed virtual machine size SKUs"
    resource_id           = ""
    resource_group_id     = "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test"
    resource_group_name   = ""
    scope                 = "resource group"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-2"
    policy_type           = "builtin"
    policy_name           = "Allowed virtual machine size SKUs"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = "test"
    scope                 = "resource group"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-1"
    policy_type           = "builtin"
    policy_name           = "Allowed locations"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "subscription"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-4"
    policy_type           = "custom"
    policy_name           = "Example Policy"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "management group"
    management_group_name = "example"
  }
]
```

<!-- BEGIN_TF_DOCS -->
# Azure Policy Assignments Terraform Module

## Overview

This Terraform module allows you to assign Azure policies at the management group, subscription, resource group, or resource level, supporting both built-in and custom policies.

## Main features
- Assign policies to management groups, subscriptions, resource groups, or resources.
- Support for both built-in and custom policy definitions.
- Flexible assignment configuration with metadata, parameters, and non-compliance messages.
- Realistic configuration example.

## Complete usage example

### YAML
```yaml
values:
  assignments:
    - name: "example-assignment-3"
      policy_type: "custom"
      policy_name: "Example Policy"
      resource_id: "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test/providers/Microsoft.KeyVault/vaults/test"
      scope: "resource"
    - name: "example-assignment-2"
      policy_type: "builtin"
      policy_name: "Allowed virtual machine size SKUs"
      resource_group_id: "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test"
      scope: "resource group"
    - name: "example-assignment-2"
      policy_type: "builtin"
      policy_name: "Allowed virtual machine size SKUs"
      resource_group_name: "test"
      scope: "resource group"
    - name: "example-assignment-1"
      policy_type: "builtin"
      policy_name: "Allowed locations"
      scope: "subscription"
    - name: "example-assignment-4"
      policy_type: "custom"
      policy_name: "Example Policy"
      management_group_name: "example"
      scope: "management group"
```

### HCL
```hcl
assignments = [
  {
    name                  = "example-assignment-3"
    policy_type           = "custom"
    policy_name           = "Example Policy"
    resource_id           = "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test/providers/Microsoft.KeyVault/vaults/-test"
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "resource"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-2"
    policy_type           = "builtin"
    policy_name           = "Allowed virtual machine size SKUs"
    resource_id           = ""
    resource_group_id     = "/subscriptions/2de29132-986f-482d-a49f-31441fc7992b/resourceGroups/test"
    resource_group_name   = ""
    scope                 = "resource group"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-2"
    policy_type           = "builtin"
    policy_name           = "Allowed virtual machine size SKUs"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = "test"
    scope                 = "resource group"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-1"
    policy_type           = "builtin"
    policy_name           = "Allowed locations"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "subscription"
    management_group_name = ""
  },
  {
    name                  = "example-assignment-4"
    policy_type           = "custom"
    policy_name           = "Example Policy"
    resource_id           = ""
    resource_group_id     = ""
    resource_group_name   = ""
    scope                 = "management group"
    management_group_name = "example"
  }
]
```

## Notes
- You can assign policies at any scope: management group, subscription, resource group, or resource.
- Both built-in and custom policies are supported.
- Use the `assignments` variable to define all assignment details.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.MD
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
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
| <a name="input_assignments"></a> [assignments](#input\_assignments) | List of objects containing all the variables for the policy assignments. | <pre>list(object({<br/>    name                  = string<br/>    policy_type           = optional(string, "builtin")<br/>    policy_name           = optional(string)<br/>    policy_definition_id  = optional(string)<br/>    resource_id           = optional(string)<br/>    resource_group_id     = optional(string)<br/>    management_group_id   = optional(string)<br/>    resource_group_name   = optional(string)<br/>    management_group_name = optional(string)<br/>    scope                 = string<br/>    description           = optional(string)<br/>    display_name          = optional(string)<br/>    enforce               = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/>    location = optional(string)<br/>    metadata = optional(string)<br/>    non_compliance_message = optional(list(object({<br/>      content                        = string<br/>      policy_definition_reference_id = optional(string)<br/>    })))<br/>    not_scopes = optional(list(string))<br/>    parameters = optional(map(any))<br/>    overrides = optional(list(object({<br/>      value = string<br/>      selectors = optional(list(object({<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      })))<br/>    })))<br/>    resource_selectors = optional(list(object({<br/>      name = optional(string)<br/>      selectors = list(object({<br/>        kind   = string<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_policy_assignment_ids"></a> [management\_group\_policy\_assignment\_ids](#output\_management\_group\_policy\_assignment\_ids) | List of all Azure management group policy assignment IDs |
| <a name="output_resource_group_policy_assignment_ids"></a> [resource\_group\_policy\_assignment\_ids](#output\_resource\_group\_policy\_assignment\_ids) | List of all Azure resource group policy assignment IDs |
| <a name="output_resource_policy_assignment_ids"></a> [resource\_policy\_assignment\_ids](#output\_resource\_policy\_assignment\_ids) | List of all Azure resource policy assignment IDs |
| <a name="output_subscription_policy_assignment_ids"></a> [subscription\_policy\_assignment\_ids](#output\_subscription\_policy\_assignment\_ids) | List of all Azure subscription policy assignment IDs |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/basic) - Policy assignments at subscription, resource group and management group scopes.

## Resources and support

- [Official Azure Policy documentation](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Terraform reference for azurerm\_management\_group\_policy\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment)
- [Terraform reference for azurerm\_resource\_group\_policy\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment)
- [Terraform reference for azurerm\_resource\_policy\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment)
- [Terraform reference for azurerm\_subscription\_policy\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->