# Azure Policy definitions Terraform module (`azure-policy-definitions`)

## Overview

This module creates one or more **custom Azure Policy definitions** (`azurerm_policy_definition`) from a **list** of policy objects. Each item supplies name, type, mode, display name, and optional rule JSON, metadata, parameters, and management group scope.

An empty **`policies`** list (`[]`, default) creates no definitions.

## Key features

- **`for_each`** over `policies` (indexed by list position).
- **Outputs**: collected IDs and names of created definitions.

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
