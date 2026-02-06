# Azure Storage Account Backup Terraform Module

## Overview

This Terraform module allows you to configure backup for Azure Storage Accounts, supporting both file shares and blob storage, with advanced retention and policy options.

## Main features
- Configure backup for file shares and blob storage.
- Support for Recovery Services Vault and Data Protection Vault.
- Advanced retention, scheduling, and policy configuration.
- Flexible tagging and resource group selection.
- Realistic configuration example.

## Complete usage example

```yaml
    values:
      tags_from_rg: true
      # General values
      backup_resource_group_name: "backup-test-rg"
      storage_account_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/xxx" # can use refs ${{tfworkspace:claim-name:outputs.id}}
      
      # Backup share values
      backup_share:
        policy_name: "daily-backup-policy"
        recovery_services_vault_name: "test-vault"
        sku: "Standard"
        soft_delete_enabled: true
        storage_mode_type: "GeoRedundant"
        cross_region_restore_enabled: true
        source_file_share_name:
          - "datadir"
        identity:
          type: "SystemAssigned"
        timezone: "UTC"
        backup:
          frequency: "Daily"
          time: "02:00"
        retention_daily:
          count: 7
        retention_weekly:
          count: 4
          weekdays:
          - "Sunday"
        retention_monthly:
          count: 12
          weekdays:
          - "Sunday"
          weeks:
          - "First"
        retention_yearly:
          count: 5
          weekdays:
          - "Sunday"
          weeks:
          - "First"
          months:
          - "January"

      # Backup blob values
      backup_blob:
        vault_name: "test-vault"
        datastore_type: "AzureBlob"
        redundancy: "GeoRedundant"
        identity_type: "SystemAssigned"
        instance_blob_name: "datadir"
        storage_account_container_names:
          - "blob1"
          - "blob2"
        role_assignment: "StorageBlobDataContributor"
        policy:
          name: "daily-blob-backup-policy"
          vault_id: "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.RecoveryServices/vaults/test-vault"
          backup_repeating_time_intervals:
          - "R/2023-01-01T02:00:00Z/P1D"
          operational_default_retention_duration: "P30D"
          retention_rule:
          - name: "daily-retention"
            duration: "P30D"
            criteria:
              days_of_week:
                - "Sunday"
            life_cycle:
              data_store_type: "VaultStore"
              duration: "P30D"
            priority: 1
          time_zone: "UTC"
          vault_default_retention_duration: "P30D"
          retention_duration: "P30D"
```


## Notes
- The `backup_share` and `backup_blob` blocks allow for advanced backup and retention configuration.
- You can use tags and inherit them from the resource group.
- Supports both Recovery Services Vault and Data Protection Vault for different backup scenarios.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── blobs.tf
├── shares.tf
├── locals.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
