# Role Assignment Module

This module creates a User Assigned Identity in Azure and assigns it role-based access control (RBAC) policies based on the role definition name or identifier.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.26.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment) | source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_assignments | A map of role assignments to create. The key is the scope, and the value is a map containing the role definition name and target ID. | `map(object({ scope = string type = string role_definition_name = optional(string) role_definition_id = optional(string) target_id = string }))` | `{}` | no |
| role_assignments.scope | The scope of the role assignment. | `string` | n/a | yes |
| role_assignments.type | The type of the role assignment. [`ServicePrincipal`, `Group`, `User`] | `string` | `ServicePrincipal` | no |
| role_assignments.role_definition_name | The name of the role definition. | `string` | n/a | yes |
| role_assignments.role_definition_id | The ID of the role definition. | `string` | n/a | yes |
| role_assignments.target_id | The ID of the target resource. | `string` | n/a | yes |

## Example

### HCL

```hcl
role_assignments = {
  # Example role assignments
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

### Yaml

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

<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to create. The key is the scope, and the value is a map containing the role definition name and target ID. | <pre>map(object({<br/>    scope                = string<br/>    target_id            = string<br/>    type                 = optional(string, "ServicePrincipal")<br/>    role_definition_name = optional(string)<br/>    role_definition_id   = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.

## Resources and support

- [Official Azure Role Assignment documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Terraform reference for azurerm\_role\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->