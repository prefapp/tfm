<!-- BEGIN_TF_DOCS -->
# Azure role assignment Terraform module

## Overview

This module creates one or more **`azurerm_role_assignment`** resources from a **map** of assignments. Each entry defines a **scope** (subscription, resource group, or resource), a **principal** (`target_id` + optional `type`: `ServicePrincipal`, `User`, or `Group`), and **either** `role_definition_name` **or** `role_definition_id` (not both).

The module does **not** create managed identities, users, or groups — it only binds RBAC at the scopes you provide.

## Key features

- **Declarative map**: `for_each` over `role_assignments` keys.
- **Flexible role reference**: Built-in role by **name** or custom role by **resource ID**.
- **Validations**: Ensures **exactly one** of `role_definition_name` and `role_definition_id` per entry, and allowed `type` values.
- **Output**: `role_assignment_id` maps each assignment key to its Azure RBAC assignment resource ID.

## Prerequisites

- **azurerm** provider configured (authentication, subscription).
- Valid **scope** paths and **principal object IDs** for your tenant.

## Basic usage

Pass `role_assignments`. Empty map (`{}`) creates no assignments.

### Example

```hcl
module "azure_role_assignment" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-role-assignment?ref=<version>"

  role_assignments = {
    rg_reader = {
      scope                = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup"
      role_definition_name = "Reader"
      target_id            = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      type                 = "ServicePrincipal"
    }
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── outputs.tf
├── role_assignment.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
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
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Map of role assignments to create. Each map key is an arbitrary assignment name (used only by Terraform); each value must include scope, target\_id, optional principal type, and exactly one of role\_definition\_name or role\_definition\_id. | <pre>map(object({<br/>    scope                  = string<br/>    target_id              = string<br/>    type                   = optional(string, "ServicePrincipal")<br/>    role_definition_name   = optional(string)<br/>    role_definition_id     = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map from each key in `var.role_assignments` to the created role assignment resource ID. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples/basic) — Runnable root module with a small `role_assignments` map (scopes, `role_definition_name` / `role_definition_id`; replace IDs before plan — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples/comprehensive) — `module.reference.hcl` and `values.reference.yaml` mirroring the historical README samples (documentation-oriented; see folder README).

## Remote Resources

Terraform resource docs use **4.26.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.26.0`).

- **Azure RBAC**: [https://learn.microsoft.com/azure/role-based-access-control/overview](https://learn.microsoft.com/azure/role-based-access-control/overview)
- **azurerm\_role\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->