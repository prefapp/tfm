# `azure-customrole`

## Overview

Terraform module that creates an **Azure custom RBAC role definition** (`azurerm_role_definition`) with configurable **assignable scopes** and a **permissions** block (`actions`, `data_actions`, `not_actions`, `not_data_actions`).

**Prerequisites**

- Terraform and provider versions in [`versions.tf`](versions.tf).
- **Azure permissions** to create role definitions at the chosen scopes (typically `Microsoft.Authorization/roleDefinitions/write` on those scopes; exact needs depend on your tenant policy).
- Valid **`azurerm`** authentication and subscription context for `plan` / `apply`.

**Behaviour notes (as implemented)**

- **`scope`** on the resource is set to **`assignable_scopes[0]`** (first list element). **`assignable_scopes`** can list additional scopes where the definition may be assigned; confirm behaviour against [provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_definition) for your use case.
- **`permissions`** lists default to empty when omitted (`optional(..., [])` in `variables.tf`).

## Basic usage

```hcl
module "custom_role" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-customrole?ref=azure-customrole-v0.2.1"

  name = "MyAppDiskReader"

  assignable_scopes = ["/subscriptions/00000000-0000-0000-0000-000000000000"]

  permissions = {
    actions = [
      "Microsoft.Compute/disks/read",
    ]
  }
}
```

Use real subscription or management-group scope IDs for `assignable_scopes`.

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | `azurerm_role_definition` |
| `variables.tf` | Inputs |
| `outputs.tf` | Role definition ID |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
