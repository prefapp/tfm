# Azure Custom Role Terraform Module

## Overview

This Terraform module allows you to create a custom role in Azure, specifying actions, data actions, and the assignable scopes.

## Main features
- Create custom roles in Azure.
- Flexible definition of actions, data actions, not actions, and not data actions.
- Support for multiple assignable scopes.

## Complete usage example

### HCL
```hcl
module "custom_role" {
  source = "./modules/azure-customrole"
  name   = "Custom Role"
  assignable_scopes = ["/subscriptions/xxx", "/subscriptions/yyy"]
  permissions = {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
    ]
    not_actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
    ]
  }
}
```

### YAML
```yaml
name: "Custom Role"
assignable_scopes:
  - "/subscriptions/xxx"
  - "/subscriptions/yyy"
permissions:
  actions:
    - "Microsoft.Compute/disks/read"
    - "Microsoft.Compute/disks/write"
  notActions:
    - "Microsoft.Authorization/*/Delete"
    - "Microsoft.Authorization/*/Write"
```

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
