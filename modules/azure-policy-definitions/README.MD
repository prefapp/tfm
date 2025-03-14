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

## Example Usage YAML

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
## Example usage HCL

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
