## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policy_definition"></a> [policy\_definition](#input\_policy\_definition) | Object containing all the variables for the policy definition. | <pre>object({<br/>    name                = string<br/>    policy_type         = string<br/>    mode                = string<br/>    display_name        = string<br/>    description         = optional(string)<br/>    management_group_id = optional(string)<br/>    policy_rule         = optional(string)<br/>    metadata            = optional(string)<br/>    parameters          = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_definition_id"></a> [policy\_definition\_id](#output\_policy\_definition\_id) | Azure Policy definition id |
| <a name="output_policy_definition_name"></a> [policy\_definition\_name](#output\_policy\_definition\_name) | Azure Policy definition name |

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
