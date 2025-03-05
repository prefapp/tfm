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
| [azurerm_resource_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policy_definition"></a> [policy\_definition](#input\_policy\_definition) | Object containing all the variables for the policy definition. | <pre>object({<br/>    name                = string<br/>    policy_type         = string<br/>    mode                = string<br/>    display_name        = string<br/>    description         = optional(string)<br/>    management_group_id = optional(string)<br/>    policy_rule         = optional(string)<br/>    metadata            = optional(string)<br/>    parameters          = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_resource_policy_assignments"></a> [resource\_policy\_assignments](#input\_resource\_policy\_assignments) | Object containing all the variables for the resource policy assignment. | <pre>object({<br/>    name                 = string<br/>    policy_definition_id = string<br/>    resource_id          = string<br/>    description          = optional(string)<br/>    display_name         = optional(string)<br/>    enforce              = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/>    location = optional(string)<br/>    metadata = optional(string)<br/>    non_compliance_message = optional(list(object({<br/>      content                        = string<br/>      policy_definition_reference_id = optional(string)<br/>    })))<br/>    not_scopes = optional(list(string))<br/>    parameters = optional(string)<br/>    overrides = optional(list(object({<br/>      value = string<br/>      selectors = optional(list(object({<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      })))<br/>    })))<br/>    resource_selectors = optional(list(object({<br/>      name = optional(string)<br/>      selectors = list(object({<br/>        kind   = string<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      }))<br/>    })))<br/>  })</pre> | n/a | yes |
| <a name="input_subscription_policy_assignments"></a> [subscription\_policy\_assignments](#input\_subscription\_policy\_assignments) | Object containing all the variables for the subscription policy assignment. | <pre>object({<br/>    name                 = string<br/>    policy_definition_id = string<br/>    subscription_id      = string<br/>    description          = optional(string)<br/>    display_name         = optional(string)<br/>    enforce              = optional(bool, true)<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/>    location = optional(string)<br/>    metadata = optional(string)<br/>    non_compliance_message = optional(list(object({<br/>      content                        = string<br/>      policy_definition_reference_id = optional(string)<br/>    })))<br/>    not_scopes = optional(list(string))<br/>    parameters = optional(string)<br/>    overrides = optional(list(object({<br/>      value = string<br/>      selectors = optional(list(object({<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      })))<br/>    })))<br/>    resource_selectors = optional(list(object({<br/>      name = optional(string)<br/>      selectors = list(object({<br/>        kind   = string<br/>        in     = optional(list(string))<br/>        not_in = optional(list(string))<br/>      }))<br/>    })))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_definition_id"></a> [policy\_definition\_id](#output\_policy\_definition\_id) | Azure Policy definition id |
| <a name="output_policy_definition_name"></a> [policy\_definition\_name](#output\_policy\_definition\_name) | Azure Policy definition name |
| <a name="output_resource_group_policy_assignment_ids"></a> [resource\_group\_policy\_assignment\_ids](#output\_resource\_group\_policy\_assignment\_ids) | List of all Azure resource group policy assignment IDs |
| <a name="output_resource_policy_assignment_ids"></a> [resource\_policy\_assignment\_ids](#output\_resource\_policy\_assignment\_ids) | List of all Azure resource policy assignment IDs |
| <a name="output_subscription_policy_assignment_ids"></a> [subscription\_policy\_assignment\_ids](#output\_subscription\_policy\_assignment\_ids) | List of all Azure subscription policy assignment IDs |

## Example Usage YAML

```yaml
values:
  policy:
    name: "example-policy"
    policy_type: "Custom"
    mode: "All"
    display_name: "Example Policy"
    description: "A sample policy to enforce location."
    management_group_id: "mgmt-group-1"
    policy_rule: |
      {
        "if": {
          "field": "location",
          "equals": "westeurope"
        },
        "then": {
          "effect": "deny"
        }
      }
    metadata: "{}"
    parameters: "{}"

  assignments:
    - name: "example-assignment-1"
      policy_definition_id: "example-policy"
      resource_id: "/subscriptions/xxxxxx/resourceGroups/example-rg1"
      scope: "/subscriptions/xxxxxx"
      description: "Assigning example policy to RG1"
      display_name: "Example Policy Assignment 1"
      enforce: true
      location: "westeurope"
      metadata: "{}"
      identity:
        type: "SystemAssigned"

    - name: "example-assignment-2"
      policy_definition_id: "example-policy"
      resource_id: "/subscriptions/xxxxxx/resourceGroups/example-rg2"
      scope: "/subscriptions/xxxxxx"
      description: "Assigning example policy to RG2"
      display_name: "Example Policy Assignment 2"
      enforce: false
      location: "northeurope"
      metadata: "{}"
      identity:
        type: "UserAssigned"
        identity_ids:
          - "/subscriptions/xxxxxx/resourceGroups/example-rg2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"
```
## Example usage HCL

```hcl
policy = {
  name                = "example-policy"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Example Policy"
  description         = "A sample policy to enforce location."
  management_group_id = "mgmt-group-1"
  policy_rule = jsonencode({
    "if" = {
      "field"  = "location"
      "equals" = "westeurope"
    }
    "then" = {
      "effect" = "deny"
    }
  })
  metadata   = "{}"
  parameters = "{}"
}

assignments = [
  {
    name                 = "example-assignment-1"
    policy_definition_id = "example-policy"
    resource_id          = "/subscriptions/xxxxxx/resourceGroups/example-rg1"
    scope                = "/subscriptions/xxxxxx"
    description          = "Assigning example policy to RG1"
    display_name         = "Example Policy Assignment 1"
    enforce              = true
    location             = "westeurope"
    metadata             = "{}"
    identity = {
      type = "SystemAssigned"
    }
  },
  {
    name                 = "example-assignment-2"
    policy_definition_id = "example-policy"
    resource_id          = "/subscriptions/xxxxxx/resourceGroups/example-rg2"
    scope                = "/subscriptions/xxxxxx"
    description          = "Assigning example policy to RG2"
    display_name         = "Example Policy Assignment 2"
    enforce              = false
    location             = "northeurope"
    metadata             = "{}"
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/xxxxxx/resourceGroups/example-rg2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-identity"]
    }
  }
]
```
