<!-- BEGIN_TF_DOCS -->
# `azure-disks-backup`

## Overview

Terraform module that provisions an **Azure Backup vault for managed disks** using the Data Protection platform: `azurerm_data_protection_backup_vault`, disk backup policies, backup instances per disk, and **RBAC** for the vault’s **system-assigned managed identity** (`Disk Snapshot Contributor` on the vault resource group, `Disk Backup Reader` on each source disk).

**Prerequisites**

- Existing **resource group** (`resource_group_name`) where the vault is created and where **disk snapshots are stored** (`snapshot_resource_group_name` in code is always this same resource group).
- **Managed disks** referenced in `backup_instances` must already exist in the given `disk_resource_group` values; the module reads them with `azurerm_managed_disk` data sources.
- **`location`** for the vault and backup instances is taken from the vault resource group data source (you do not pass `location` as a variable).

**Behaviour notes (as implemented)**

- **`backup_policies`**: `for_each` is keyed by `policy.name`; each `backup_policy_name` in `backup_instances` must match one of those names.
- **`backup_instances`**: `for_each` is keyed by **`disk_name`**. Each `disk_name` must be **unique** in the list; duplicate names would collide in state.
- **Snapshots**: `azurerm_data_protection_backup_instance_disk` sets `snapshot_resource_group_name` to **`var.resource_group_name`** (the vault resource group). There is **no** per-instance field for snapshot RG in `variables.tf`—older README examples that showed `snapshot_resource_group_name` on each instance do not match the current code.
- **Tags**: Same pattern as other Azure modules—`tags_from_rg` merges resource group tags with `tags`.
- A **commented** `null_resource` validation in `data.tf` once aimed to forbid disks in the same RG as the vault; it is **not active**. Confirm Microsoft / operational constraints for your subscription if you colocate resources.

## Basic usage

```hcl
module "disks_backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks-backup?ref=azure-disks-backup-v1.2.3"

  resource_group_name = "example-backup-rg"
  vault_name            = "example-disk-backup-vault"

  datastore_type             = "VaultStore"
  redundancy                 = "LocallyRedundant"
  soft_delete                = "Off"
  retention_duration_in_days = 14

  backup_policies = [
    {
      name                            = "daily"
      backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT24H"]
      default_retention_duration      = "P7D"
      time_zone                       = "Coordinated Universal Time"
      retention_rules = [
        {
          name     = "Daily"
          duration = "P7D"
          priority = 25
          criteria = { absolute_criteria = "FirstOfDay" }
        }
      ]
    }
  ]

  backup_instances = [
    {
      disk_name           = "data-01"
      disk_resource_group = "example-data-rg"
      backup_policy_name  = "daily"
    }
  ]

  tags_from_rg = false
  tags         = { workload = "example" }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `backup_vault.tf` | Backup vault + managed identity |
| `backup_policy.tf` | Disk backup policies |
| `protection_instance.tf` | Backup instances (disks) |
| `role_assignments.tf` | RBAC for vault identity |
| `data.tf` | Resource group + managed disk data sources |
| `locals.tf` | Tag merge |
| `variables.tf` | Inputs |
| `outputs.tf` | Outputs |
| `versions.tf` | Terraform and provider versions |
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk) | resource |
| [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_role_assignment.this_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this_rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_instances"></a> [backup\_instances](#input\_backup\_instances) | List of backup instances. | <pre>list(object({<br/>    disk_name           = string<br/>    disk_resource_group = string<br/>    backup_policy_name  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_backup_policies"></a> [backup\_policies](#input\_backup\_policies) | List of backup policies. | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    default_retention_duration      = string<br/>    time_zone                       = string<br/>    retention_rules = list(object({<br/>      name     = string<br/>      duration = string<br/>      priority = number<br/>      criteria = object({<br/>        absolute_criteria = string<br/>      })<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_datastore_type"></a> [datastore\_type](#input\_datastore\_type) | The type of datastore. | `string` | `"VaultStore"` | no |
| <a name="input_redundancy"></a> [redundancy](#input\_redundancy) | The redundancy type. | `string` | `"LocallyRedundant"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group used for the backup vault and backup instances. | `string` | n/a | yes |
| <a name="input_retention_duration_in_days"></a> [retention\_duration\_in\_days](#input\_retention\_duration\_in\_days) | The retention duration in days before the backup is purged. 14 days free. | `number` | `14` | no |
| <a name="input_soft_delete"></a> [soft\_delete](#input\_soft\_delete) | Soft delete setting for the vault (`AlwaysOn`, `On`, or `Off`). | `string` | `"Off"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | The name of the backup vault. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | Resource ID of the Data Protection backup vault. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples/basic) — Backup vault, policies, and disk backup instances; ensure managed disks exist or adjust inputs before apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples/comprehensive) — Illustrative `values.reference.yaml` for multiple policies and instances (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.5.0**, matching the pinned `azurerm` version in `versions.tf`.

- **Azure Backup for managed disks**: [https://learn.microsoft.com/azure/backup/disk-backup-overview](https://learn.microsoft.com/azure/backup/disk-backup-overview)
- **azurerm\_data\_protection\_backup\_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault)
- **azurerm\_data\_protection\_backup\_policy\_disk**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk)
- **azurerm\_data\_protection\_backup\_instance\_disk**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk)
- **azurerm\_role\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment)
- **azurerm\_resource\_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group)
- **azurerm\_managed\_disk** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
