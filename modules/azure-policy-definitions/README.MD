<!-- BEGIN_TF_DOCS -->
# Azure Policy Definitions Terraform Module

## Overview

This Terraform module allows you to create custom Azure Policy Definitions, supporting all policy rule, metadata, and parameter options.

## Main features
- Create custom policy definitions with flexible rules and metadata.
- Support for all policy definition fields, including parameters and management group assignment.
- Realistic configuration example.

## Complete usage example

### YAML
```yaml
values:
  policies:
    - name: "example-policy"
      policy_type: "Custom"
      mode: "All"
      display_name: "Example Policy"
      description: "A sample policy to audit location."
      policy_rule: |
        {
          "if": {
            "field": "location",
            "equals": "westeurope"
          },
          "then": {
            "effect": "audit"
          }
        }
    - name: "example-policy2"
      policy_type: "Custom"
      mode: "All"
      display_name: "Example Policy 2"
      description: "A sample policy to audit location."
      policy_rule: |
        {
          "if": {
            "field": "location",
            "equals": "westeurope"
          },
          "then": {
            "effect": "audit"
          }
        }
```

### HCL
```hcl
policies = [
  {
    name                = "example-policy"
    policy_type         = "Custom"
    mode                = "All"
    display_name        = "Example Policy"
    description         = "A sample policy to audit location."
    policy_rule = jsonencode({
      "if" = {
        "field"  = "location"
        "equals" = "westeurope"
      }
      "then" = {
        "effect" = "audit"
      }
    })
    metadata   = "{}"
    parameters = "{}"
  },
  {
    name                = "example-policy2"
    policy_type         = "Custom"
    mode                = "All"
    display_name        = "Example Policy 2"
    description         = "A sample policy to audit location."
    policy_rule = jsonencode({
      "if" = {
        "field"  = "location"
        "equals" = "westeurope"
      }
      "then" = {
        "effect" = "audit"
      }
    })
  }
]
```

## Notes
- You can define any custom policy rule, metadata, and parameters.
- Assign policies to management groups if needed.
- Use the `policies` variable to define all policy details.

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
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policies"></a> [policies](#input\_policies) | List of objects containing all the variables for the policy definitions. | <pre>list(object({<br/>    name                = string<br/>    policy_type         = string<br/>    mode                = string<br/>    display_name        = string<br/>    description         = optional(string)<br/>    management_group_id = optional(string)<br/>    policy_rule         = optional(string)<br/>    metadata            = optional(string)<br/>    parameters          = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_definition_ids"></a> [policy\_definition\_ids](#output\_policy\_definition\_ids) | List of all Azure Policy definition IDs |
| <a name="output_policy_definition_names"></a> [policy\_definition\_names](#output\_policy\_definition\_names) | List of all Azure Policy definition names |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples/basic) - Custom policy definitions for common governance scenarios.

## Resources and support

- [Official Azure Policy documentation](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Terraform reference for azurerm\_policy\_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->