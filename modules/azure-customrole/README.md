<!-- BEGIN_TF_DOCS -->
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
| `docs/header.md` | README header content (used for terraform-docs generation) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes) | One or more assignable scopes for this Role Definition. The first one will become the scope at which the Role Definition applies to. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Role Definition | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A permissions block with possible 'actions', 'data\_actions', 'not\_actions' and/or 'not\_data\_actions'. | <pre>object({<br/>    actions          = optional(list(string), [])<br/>    data_actions     = optional(list(string), [])<br/>    not_actions      = optional(list(string), [])<br/>    not_data_actions = optional(list(string), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | GUID of the custom role definition (`role_definition_id` from the created resource). |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples/basic) — Runnable minimal example: one custom role at subscription scope (see folder README for `terraform plan` / `apply` notes).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples/comprehensive) — Documentation-only reference with `values.reference.yaml` for assignable scopes and permissions (see folder README).

## Resources

Terraform resource docs use **4.16.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.16.0`).

- **Azure custom roles (RBAC)**: [https://learn.microsoft.com/azure/role-based-access-control/custom-roles](https://learn.microsoft.com/azure/role-based-access-control/custom-roles)
- **azurerm\_role\_definition**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_definition)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->