# Azure Role Assignment Terraform Module

## Overview

This Terraform module allows you to create role assignments (RBAC) for User Assigned Identities, Service Principals, Users, or Groups in Azure, using either role definition names or IDs.

## Main features
- Assign roles to Service Principals, Users, or Groups at any scope.
- Support for both role definition names and IDs.
- Flexible configuration using HCL or YAML.
- Realistic configuration example.

## Complete usage example

### HCL
```hcl
role_assignments = {
  foo = {
    scope                = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup"
    role_definition_name = "Reader"
    target_id            = "12345678-1234-1234-1234-123456789012"
  },
  bar = {
    scope                = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM"
    role_definition_id   = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/providers/Microsoft.Authorization/roleDefinitions/12345678-1234-1234-1234-123456789012"
    target_id            = "87654321-4321-4321-4321-210987654321"
  }
}
```

### YAML
```yaml
role_assignments:
  foo:
    scope: "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup"
    role_definition_name: "Reader"
    target_id: "12345678-1234-1234-1234-123456789012"
  bar:
    scope: "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM"
    role_definition_id: "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/providers/Microsoft.Authorization/roleDefinitions/12345678-1234-1234-1234-123456789012"
    target_id: "87654321-4321-4321-4321-210987654321"
```

## Notes
- You can use either `role_definition_name` or `role_definition_id` for each assignment.
- The `target_id` can be a Service Principal, User, or Group object ID.
- Assignments can be created at any Azure scope (subscription, resource group, resource, etc).

## File structure

```
.
├── role_assignment.tf
├── variables.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
