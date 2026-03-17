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