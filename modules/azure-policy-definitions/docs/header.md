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