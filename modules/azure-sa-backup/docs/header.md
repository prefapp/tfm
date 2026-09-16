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
