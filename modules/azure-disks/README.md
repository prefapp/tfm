<!-- BEGIN_TF_DOCS -->
# `azure-disks`

## Overview

Terraform module that creates one or more **Azure managed disks** (`azurerm_managed_disk`) in an existing resource group, with optional **Azure RBAC role assignments** scoped to each disk. Tags can be merged from the resource group or set only from module input.

**Prerequisites**

- Existing **resource group** (`resource_group_name`).
- **`location`** consistent with that resource group (the module does not read location from the data source).

**Behaviour notes (as implemented)**

- **`disks`** must be a **list** of objects; each object must include **`name`** (used as the Terraform `for_each` key and as the Azure disk name). Optional keys supported by `lookup` in [`main.tf`](main.tf): `storage_account_type` (default `StandardSSD_LRS`), `create_option` (default `Empty`), `source_resource_id` (default `null`), `disk_size_gb` (default `4`).
- **`lifecycle.ignore_changes`** includes **`disk_size_gb`** so in-cluster resizes (for example via CSI) do not fight Terraform.
- **`assign_role`**: when `true`, creates `azurerm_role_assignment` per disk. The resource uses `lookup(each.value, "role_definition_name", "Contributor")` where `each.value` is the **managed disk resource**, not your `disks` list entry—so the lookup does not read per-disk settings from `var.disks`; the effective role name is **`Contributor`** in normal use. The root module variable **`role_definition_name`** is **not referenced** in the current implementation.
- **`principal_id`**: required when `assign_role` is `true` (use a valid object ID; the default empty string will fail assignment).

## Basic usage

```hcl
module "disks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks?ref=azure-disks-v1.1.2"

  resource_group_name = "example-rg"
  location              = "westeurope"

  disks = [
    { name = "data-01", disk_size_gb = 64, storage_account_type = "Premium_LRS" },
    { name = "data-02" }
  ]

  assign_role  = false
  principal_id = ""

  tags_from_rg = true
  tags         = { workload = "example" }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Resource group data source, managed disks, role assignments |
| `locals.tf` | Tag merge |
| `variables.tf` | Inputs |
| `outputs.tf` | Disk names and IDs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_role_assignment.role_assignment_over_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_role"></a> [assign\_role](#input\_assign\_role) | Whether to assign a role definition to the managed disk. | `bool` | `false` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | A list of managed disk configurations. | `list(any)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the managed disk should be created. | `string` | n/a | yes |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | The ID of the principal to assign the role definition to. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the managed disk should be created. | `string` | n/a | yes |
| <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name) | The name of the role definition to assign to the managed disk. | `string` | `"Contributor"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disk_ids"></a> [disk\_ids](#output\_disk\_ids) | Resource IDs of created managed disks. |
| <a name="output_disk_names"></a> [disk\_names](#output\_disk\_names) | Names of created managed disks. |

## Generated README tables

With **terraform-docs**, **Requirements** shows provider constraints from `versions.tf`. The provider documentation links below use **4.5.0** as the reference baseline aligned with that constraint.

## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-disks/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-disks/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf`)

Constraint: `azurerm` `~> 4.5.0` — doc links use **4.5.0** as the reference baseline.

- [azurerm\_managed\_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/managed_disk)
- [azurerm\_role\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment)
- [azurerm\_resource\_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group)

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->