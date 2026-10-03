<!-- BEGIN_TF_DOCS -->
# **Azure Storage Account Backup Terraform Module**

## Overview

This module configures backup for an existing Azure Storage account. It can protect one Azure Files share through a Recovery Services vault, registering the storage account as a protection container and applying a file-share backup policy.

It can independently protect blob containers with a Data Protection vault, a blob-storage backup policy, and a backup instance. When the blob vault uses a system-assigned managed identity, the module grants that identity the configured role over the source storage account so backup operations can access the selected containers. The backup instance does not explicitly depend on this role assignment, so Terraform can create both concurrently and a subsequent apply may be required after the role assignment has propagated.

Use the module when backup infrastructure and the source storage account are already planned separately, such as development, staging, and production workloads. Both vault types are optional, so configure only the backup service required for the storage data being protected.

## Key Features

- **Azure Files backup**: Creates a Recovery Services vault, storage-account protection container, file-share policy, and protected-share resource for one file share.
- **Blob backup**: Creates a Data Protection vault, blob backup policy, and backup instance for selected blob containers.
- **Vault identity access**: Assigns the configured Azure role to the Data Protection vault system-assigned identity on the source storage account.
- **Retention schedules**: Supports daily, weekly, monthly, and yearly retention for file shares, plus repeating intervals and retention rules for blobs.
- **Tag inheritance**: Optionally merges tags from the backup resource group with module tags; explicit module tags take precedence.

## Basic Usage

### Azure Files Share Backup

This configuration protects one existing file share using a daily Recovery Services vault policy. The storage account and file share must exist before applying the module.

```hcl
module "storage_backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-sa-backup"

  backup_resource_group_name = "example-backup-rg"
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-storage-rg/providers/Microsoft.Storage/storageAccounts/examplestorage"

  backup_share = {
    policy_name                  = "daily-file-share-backup"
    recovery_services_vault_name = "example-file-share-vault"
    sku                          = "Standard"
    source_file_share_name       = ["documents"]
    backup = {
      frequency = "Daily"
      time      = "02:00"
    }
    retention_daily = {
      count = 30
    }
  }
}
```

### Blob Container Backup

This configuration protects selected blob containers through a Data Protection vault. Set `identity_type` to `SystemAssigned` so the module can assign the required role to the storage account.

```hcl
module "storage_backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-sa-backup"

  backup_resource_group_name = "example-backup-rg"
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-storage-rg/providers/Microsoft.Storage/storageAccounts/examplestorage"

  backup_blob = {
    vault_name                      = "example-blob-backup-vault"
    datastore_type                  = "VaultStore"
    redundancy                      = "LocallyRedundant"
    identity_type                   = "SystemAssigned"
    role_assignment                 = "Storage Account Backup Contributor"
    instance_blob_name              = "example-blob-backup"
    storage_account_container_names = ["archive", "exports"]
    policy = {
      name                                   = "daily-blob-backup"
      backup_repeating_time_intervals        = ["R/2024-01-01T02:00:00+00:00/PT24H"]
      operational_default_retention_duration = "P30D"
    }
  }
}
```

## Importing Existing Infrastructure

Import each existing resource independently. Replace the placeholders with your subscription, resource group, vault, policy, storage account, and protected resource names. Resources with `[0]` exist only when the corresponding `backup_share` or `backup_blob` input is configured.

```bash
terraform import 'module.storage_backup.azurerm_recovery_services_vault.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.RecoveryServices/vaults/<recovery-vault>'
terraform import 'module.storage_backup.azurerm_backup_container_storage_account.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.RecoveryServices/vaults/<recovery-vault>/backupFabrics/Azure/protectionContainers/StorageContainer;storage;<storage-rg>;<storage-account>'
terraform import 'module.storage_backup.azurerm_backup_policy_file_share.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.RecoveryServices/vaults/<recovery-vault>/backupPolicies/<file-share-policy>'
terraform import 'module.storage_backup.azurerm_backup_protected_file_share.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.RecoveryServices/vaults/<recovery-vault>/backupFabrics/Azure/protectionContainers/StorageContainer;storage;<storage-rg>;<storage-account>/protectedItems/AzureFileShare;<file-share>'
terraform import 'module.storage_backup.azurerm_data_protection_backup_vault.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.DataProtection/backupVaults/<data-protection-vault>'
terraform import 'module.storage_backup.azurerm_data_protection_backup_policy_blob_storage.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.DataProtection/backupVaults/<data-protection-vault>/backupPolicies/<blob-policy>'
terraform import 'module.storage_backup.azurerm_data_protection_backup_instance_blob_storage.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<backup-rg>/providers/Microsoft.DataProtection/backupVaults/<data-protection-vault>/backupInstances/<blob-instance>'
terraform import 'module.storage_backup.azurerm_role_assignment.this[0]' '/subscriptions/<subscription-id>/resourceGroups/<storage-rg>/providers/Microsoft.Storage/storageAccounts/<storage-account>/providers/Microsoft.Authorization/roleAssignments/<role-assignment-guid>'
```

Import `azurerm_backup_protected_file_share.this` once for every configured file share, incrementing the index. Azure may encode protected item names differently from the file-share name; retrieve the exact protected-item ARM ID from Azure before importing it. Import the role assignment only when `backup_blob.identity_type` is set.

## Delete Behavior

Destroying a configured backup removes its policy, protected-resource registration or backup instance, vault, and any blob-vault role assignment. This stops future backup and restores; retained recovery data, soft-delete behavior, and deletion eligibility are controlled by Azure service settings and may prevent immediate deletion. Confirm retention, soft-delete, and recovery requirements before removing protection from production data.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.6.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_container_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_backup_policy_file_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share) | resource |
| [azurerm_backup_protected_file_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) | resource |
| [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) | resource |
| [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_recovery_services_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_blob"></a> [backup\_blob](#input\_backup\_blob) | Specifies the backup configuration for the storage blob | <pre>object({<br/>    vault_name                      = string<br/>    datastore_type                  = string<br/>    redundancy                      = string<br/>    identity_type                   = optional(string)<br/>    role_assignment                 = string<br/>    instance_blob_name              = string<br/>    storage_account_container_names = optional(list(string))<br/>    policy = object({<br/>      name                                   = string<br/>      backup_repeating_time_intervals        = optional(list(string))<br/>      operational_default_retention_duration = optional(string)<br/>      retention_rule = optional(list(object({<br/>        name     = string<br/>        duration = string<br/>        criteria = object({<br/>          absolute_criteria      = optional(string)<br/>          days_of_month          = optional(list(number))<br/>          days_of_week           = optional(list(string))<br/>          months_of_year         = optional(list(string))<br/>          scheduled_backup_times = optional(list(string))<br/>          weeks_of_month         = optional(list(string))<br/>        })<br/>        life_cycle = object({<br/>          data_store_type = string<br/>          duration        = string<br/>        })<br/>        priority = number<br/>      })))<br/>      time_zone                        = optional(string)<br/>      vault_default_retention_duration = optional(string)<br/>      retention_duration               = optional(string)<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_backup_resource_group_name"></a> [backup\_resource\_group\_name](#input\_backup\_resource\_group\_name) | The name for the resource group for the backups | `string` | n/a | yes |
| <a name="input_backup_share"></a> [backup\_share](#input\_backup\_share) | Specifies the backup configuration for the storage share | <pre>object({<br/>    policy_name                  = string<br/>    recovery_services_vault_name = string<br/>    sku                          = string<br/>    soft_delete_enabled          = optional(bool)<br/>    storage_mode_type            = optional(string, "GeoRedundant")<br/>    cross_region_restore_enabled = optional(bool)<br/>    source_file_share_name       = list(string)<br/>    identity = optional(object({<br/>      type         = optional(string, "SystemAssigned")<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    encryption = optional(object({<br/>      key_id                            = optional(string, null)<br/>      infrastructure_encryption_enabled = optional(bool, false)<br/>      user_assigned_identity_id         = optional(string, null)<br/>      use_system_assigned_identity      = optional(bool, false)<br/>    }))<br/>    timezone = optional(string)<br/>    backup = object({<br/>      frequency = string<br/>      time      = string<br/>    })<br/>    retention_daily = object({<br/>      count = number<br/>    })<br/>    retention_weekly = optional(object({<br/>      count    = number<br/>      weekdays = optional(list(string), ["Sunday"])<br/>    }))<br/>    retention_monthly = optional(object({<br/>      count    = number<br/>      weekdays = optional(list(string), ["Sunday"])<br/>      weeks    = optional(list(string), ["First"])<br/>      days     = optional(list(number))<br/>    }))<br/>    retention_yearly = optional(object({<br/>      count    = number<br/>      months   = optional(list(string), ["January"])<br/>      weekdays = optional(list(string), ["Sunday"])<br/>      weeks    = optional(list(string), ["First"])<br/>      days     = optional(list(number))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_lifecycle_policy_rule"></a> [lifecycle\_policy\_rule](#input\_lifecycle\_policy\_rule) | n/a | <pre>list(object({<br/>    name    = string<br/>    enabled = bool<br/>    filters = object({<br/>      prefix_match = list(string)<br/>      blob_types   = list(string)<br/>    })<br/>    actions = object({<br/>      base_blob = object({ delete_after_days_since_creation_greater_than = number })<br/>      snapshot  = object({ delete_after_days_since_creation_greater_than = number })<br/>      version   = object({ delete_after_days_since_creation = number })<br/>    })<br/>  }))</pre> | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | The ID of the storage account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples):

- [File share backup](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/file-share-backup) - Recovery Services vault and daily policy for an existing Azure Files share.
- [Blob backup](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/blob-backup) - Data Protection vault, policy, backup instance, and storage-account role assignment for blob containers.

## Remote Resources

- **Azure Backup for Azure Files**: [https://learn.microsoft.com/azure/backup/azure-file-share-backup-overview](https://learn.microsoft.com/azure/backup/azure-file-share-backup-overview)
- **Azure Blob backup**: [https://learn.microsoft.com/azure/backup/blob-backup-overview](https://learn.microsoft.com/azure/backup/blob-backup-overview)
- **Recovery Services vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault)
- **Data Protection backup vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- **Terraform AzureRM Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->