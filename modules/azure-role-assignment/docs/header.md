# Azure role assignment Terraform module

## Overview

This module creates one or more **`azurerm_role_assignment`** resources from a **map** of assignments. Each entry defines a **scope** (subscription, resource group, or resource), a **principal** (`target_id` + optional `type`: `ServicePrincipal`, `User`, or `Group`), and **either** `role_definition_name` **or** `role_definition_id` (not both).

The module does **not** create managed identities, users, or groups — it only binds RBAC at the scopes you provide.

## Key features

- **Declarative map**: `for_each` over `role_assignments` keys.
- **Flexible role reference**: Built-in role by **name** or custom role by **resource ID**.
- **Validations**: Ensures **exactly one** of `role_definition_name` and `role_definition_id` per entry, and allowed `type` values.

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
