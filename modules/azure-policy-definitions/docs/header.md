# Azure Policy definitions Terraform module (`azure-policy-definitions`)

## Overview

This module creates one or more **custom Azure Policy definitions** (`azurerm_policy_definition`) from a **list** of policy objects. Each item supplies name, type, mode, display name, and optional rule JSON, metadata, parameters, and management group scope.

An empty **`policies`** list (`[]`, default) creates no definitions.

## Key features

- **`for_each`** keyed by **`policy.name`** (must be unique per entry); reordering the list does not change resource addresses. Output list order follows **lexicographic sort of `name`**, not the input list order.
- **Outputs**: collected IDs and names of created definitions.

## Notes

- **State migration**: If you previously used a module version that keyed `for_each` by **list index**, upgrading to **`policy.name` keys** changes resource addresses. Use `terraform state mv` (from `azurerm_policy_definition.this[\"0\"]` to `azurerm_policy_definition.this[\"<policy-name>\"]`) or accept one-time replacement—plan carefully.

## Prerequisites

- **azurerm** provider configured with permissions to create policy definitions (subscription and/or management group, depending on `management_group_id`).

## Basic usage

```hcl
module "policy_definitions" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-policy-definitions?ref=<version>"

  policies = [
    {
      name         = "example-audit-location"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Audit specific location"
      description  = "Sample policy."
      policy_rule = jsonencode({
        if = {
          field  = "location"
          equals = "westeurope"
        }
        then = {
          effect = "audit"
        }
      })
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
