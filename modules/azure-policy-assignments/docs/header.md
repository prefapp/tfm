# Azure Policy assignments Terraform module (`azure-policy-assignments`)

## Overview

This module creates **Azure Policy assignments** at one of four **scopes**, driven by the **`scope`** field on each item in **`assignments`**:

| `scope` value (string) | Resource |
|------------------------|----------|
| `resource` | `azurerm_resource_policy_assignment` |
| `resource group` | `azurerm_resource_group_policy_assignment` |
| `subscription` | `azurerm_subscription_policy_assignment` (current subscription from provider) |
| `management group` | `azurerm_management_group_policy_assignment` |

Policy definition resolution: resources use **`coalesce(policy_definition_id, data lookup)`**. The **`azurerm_policy_definition`** data source runs only when **`policy_name` is non-null** and **`policy_definition_id` is omitted or `null`** (not an empty string `""`—use `null` or omit the attribute so the lookup by display name runs). Assignments that pass only an ID do not trigger that data source. Optional **`parameters`** are a map and are **JSON-encoded** for the assignment resource.

An empty **`assignments`** list (`[]`, default) creates nothing.

## Key features

- **Built-in vs custom**: `policy_type` is `builtin` or `custom` (validated); default `builtin`.
- **Outputs**: separate lists of assignment IDs per scope type.

## Prerequisites

- **azurerm** provider configured; permissions to assign policies at the chosen scopes.
- For **`policy_name`** lookup, a matching policy definition must exist in the tenant.

## Basic usage

```hcl
module "policy_assignments" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-policy-assignments?ref=<version>"

  assignments = [
    {
      name          = "audit-locations-sub"
      policy_type   = "builtin"
      policy_name   = "Allowed locations"
      scope         = "subscription"
    }
  ]
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```
