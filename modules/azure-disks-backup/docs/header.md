# Azure Disks Backup Terraform Module

## Overview

This Terraform module allows you to create and configure managed disks backups in Azure, including:
- Creation of Recovery Services vault.
- Definition of custom backup policies.
- Creation of backup instances for specific disks.
- Support for tags and inheritance from the Resource Group.

## Main features
- Configurable vault and backup policies.
- Support for multiple disks and policies.
- Retention, redundancy, and soft delete control.
- Realistic configuration example.

## Complete usage example

```hcl
resource_group_name = "bk-disks"
vault_name          = "bk-disks"
tags_from_rg        = true
tags = {
  Environment = "Production"
  Project     = "Azure Disks Backup"
}
datastore_type      = "VaultStore"
redundancy          = "LocallyRedundant"
soft_delete         = "Off"
retention_duration_in_days = 30
backup_policies = [
  {
    name = "foo-policy"
    backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT1H"]
    default_retention_duration = "P7D"
    time_zone = "Coordinated Universal Time"
    retention_rules = [
      {
        name = "Daily"
        duration = "P7D"
        priority = 25
        criteria = { absolute_criteria = "FirstOfDay" }
      }
    ]
  },
  {
    name = "bar-policy"
    backup_repeating_time_intervals = ["R/2024-11-01T10:00:00+00:00/PT2H"]
    default_retention_duration = "P14D"
    time_zone = "Pacific Standard Time"
    retention_rules = [
      {
        name = "Weekly"
        duration = "P14D"
        priority = 30
        criteria = { absolute_criteria = "FirstOfWeek" }
      },
      {
        name = "Monthly"
        duration = "P30D"
        priority = 35
        criteria = { absolute_criteria = "FirstOfMonth" }
      }
    ]
  }
]
backup_instances = [
  {
    disk_name = "foo-disk"
    disk_resource_group = "foo-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "foo-policy"
  },
  {
    disk_name = "foo-disk"
    disk_resource_group = "foo-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "bar-policy"
  },
  {
    disk_name = "bar-disk"
    disk_resource_group = "bar-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "bar-policy"
  }
]
```

## Notes
- The resource_group_name must be the same for the vault and the snapshots.
- Disks can be in different resource groups than the vault.
- The module will throw an error if the disk and vault resource group are the same.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
