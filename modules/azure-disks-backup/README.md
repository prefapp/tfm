# Azure Disks Backup Module

## Overview

This module creates and configures Azure Backup for managed disks. It sets up a Recovery Services vault, backup policies, and backup instances for specified disks. 

## DOC

- [Resource terraform - azurerm_data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- [Resource terraform - azurerm_data_protection_backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy)
- [Resource terraform - azurerm_data_protection_backup_instance_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk)
- [Resource terraform - azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

## Notes

- This module presupposes that:
  - The `resource_group_name` was used to create the Recovery Services vault and backuo instances.
  - The resource group where the snapshot will be stored is the same as the vault.
  - The disk/s resource groups/s are diferent from the vault resource group, otherwise, the module raises an error.

## Usage

### Set a module

```terraform
module "disks-backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks-backup?ref=<version>"
}
```

### Set a data .tfvars

#### Example

```hcl
# The name of the resource group where the backup vault and related resources will be created
resource_group_name = "bk-disks"

# The name of the Recovery Services vault
vault_name          = "bk-disks"

# Whether to use resource group  tags as base for module tags
tags_from_rg      = true

# Tags to apply to resources
tags = {
  Environment = "Production"
  Project     = "Azure Disks Backup"  
}

# The type of datastore to use for backups (Possible values are ArchiveStore, OperationalStore, SnapshotStore and VaultStore)
datastore_type      = "VaultStore"

# The redundancy option for the backup vault (LocallyRedundant or GeoRedundant)
redundancy          = "LocallyRedundant"

# Whether soft delete is enabled or disabled for the vault
soft_delete         = "Off"

# Default retention duration for backups in days before they are deleted (14 days free)
retention_duration_in_days = 30

# List of backup policies to be created
backup_policies = [
  {
    # Name of the backup policy
    name                          = "foo-policy"

    # Time intervals for repeating backups
    backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT1H"]

    # Default retention duration for backups
    default_retention_duration    = "P7D"

    # Time zone for the backup schedule
    time_zone                     = "Coordinated Universal Time"

    # Retention rules for the backup policy
    retention_rules = [
      {
        # Name of the retention rule
        name     = "Daily"

        # Duration for which backups are retained
        duration = "P7D"

        # Priority of the retention rule
        priority = 25

        # Criteria for applying the retention rule
        criteria = {
          absolute_criteria = "FirstOfDay"
        }
      }
    ]
  },
  {
    name                          = "bar-policy"
    backup_repeating_time_intervals = ["R/2024-11-01T10:00:00+00:00/PT2H"]
    default_retention_duration    = "P14D"
    time_zone                     = "Pacific Standard Time"
    retention_rules = [
      {
        name     = "Weekly"
        duration = "P14D"
        priority = 30
        criteria = {
          absolute_criteria = "FirstOfWeek"
        }
      },
      {
        name     = "Monthly"
        duration = "P30D"
        priority = 35
        criteria = {
          absolute_criteria = "FirstOfMonth"
        }
      }
    ]
  }
]

# List of backup instances to be created
backup_instances = [
  {
    # Name of the disk to be backed up
    disk_name                     = "foo-disk"

    # Resource group where the disk is located
    disk_resource_group           = "foo-data"

    # Resource group where the snapshot will be stored
    snapshot_resource_group_name  = "bk-disks"

    # Name of the backup policy to apply
    backup_policy_name            = "foo-policy"
  },
  {
    disk_name                     = "foo-disk"
    disk_resource_group           = "foo-data"
    snapshot_resource_group_name  = "bk-disks"
    backup_policy_name            = "bar-policy"
  },
  {
    disk_name                     = "bar-disk"
    disk_resource_group           = "bar-data"
    snapshot_resource_group_name  = "bk-disks"
    backup_policy_name            = "bar-policy"
  }
]
```

## Inputs

| Name | Description | Type | Default | Required |
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_vault_name"></a> [vault_name](#input_vault_name) | The name of the backup vault. | `string` | n/a | yes |
| <a name="input_datastore_type"></a> [datastore_type](#input_datastore_type) | The type of datastore. Possible values are ArchiveStore, OperationalStore, SnapshotStore and VaultStore. | `string` | `"VaultStore"` | no |
| <a name="input_redundancy"></a> [redundancy](#input_redundancy) | The redundancy type. | `string` | `"LocallyRedundant"` | no |
| <a name="input_soft_delete"></a> [soft_delete](#input_soft_delete) | Enable soft delete. | `string` | `"Off"` | no |
| <a name="input_retention_duration_in_days"></a> [retention_duration_in_days](#input_retention_duration_in_days) | Default retention duration in days. | `number` | `14` | no |
| <a name="input_backup_policies"></a> [backup_policies](#input_backup_policies) | List of backup policies. | `list(object({ name = string, backup_repeating_time_intervals = list(string), default_retention_duration = string, time_zone = string, retention_rules = list(object({ name = string, duration = string, priority = number, criteria = object({ absolute_criteria = string }) })) }))` | n/a | yes |
| <a name="input_backup_instances"></a> [backup_instances](#input_backup_instances) | List of backup instances. | `list(object({ disk_name = string, disk_resource_group = string, snapshot_resource_group_name = string, backup_policy_name = string }))` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

- `vault_id`: The ID of the Recovery Services vault
