# Azure Backup Vault Terraform Module

## Overview

This Terraform module creates and configures an Azure Data Protection Backup Vault and associated backup instances and policies. It supports:

- **Vault**: Data Protection Backup Vault with configurable redundancy, retention, immutability and soft delete.
- **PostgreSQL Flexible Server**: Backup policies and instances for Azure Database for PostgreSQL.
- **MySQL Flexible Server**: Backup policies and instances for Azure Database for MySQL.
- **Disks**: Backup policies and instances for managed disks.
- **Blob storage**: Backup policies and instances for storage account blobs.
- **Kubernetes**: Backup policies and instances for AKS clusters (including extension and trusted access).

## Main features

- Single module to manage vault, policies and instances for multiple data source types.
- Configurable retention rules, schedules and redundancy.
- Optional tags and inheritance from the backup resource group.
- Support for Kubernetes backup extension and snapshot resource group.

## Example

```yaml
values:
  # COMMON configuration
  backup_resource_group_name: my-backup-rg

  # VAULT configuration
  vault:
    name: my-backup-vault
    datastore_type: VaultStore
    redundancy: LocallyRedundant
    retention_duration_in_days: 30
    immutability: Disabled
    soft_delete: Off

  # POSTGRESQL configuration
  postgresql_policies:
    - name: daily
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      default_retention_rule:
        life_cycle:
          duration: "P30D"
          data_store_type: VaultStore
      retention_rule:
        - name: daily
          priority: 1
          life_cycle:
            duration: "P7D"
            data_store_type: VaultStore
          criteria:
            absolute_criteria: "FirstOfDay"
    - name: weekly
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      default_retention_rule:
        life_cycle:
          duration: "P30D"
          data_store_type: VaultStore
      retention_rule:
        - name: weekly
          priority: 1
          life_cycle:
            duration: "P30D"
            data_store_type: VaultStore
          criteria:
            absolute_criteria: "FirstOfDay"

  postgresql_instances:
    - name: pg1-backup
      server_name: my-postgres-server-1
      resource_group_name: my-db-rg
      policy_key: daily
    - name: pg2-backup
      server_name: my-postgres-server-2
      resource_group_name: my-db-rg-2
      policy_key: weekly

  ## MYSQL configuration is disabled by Azure for the moment due to issues with the provider
  # MYSQL configuration
  mysql_policies:
    - name: daily
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      default_retention_rule:
        life_cycle:
          duration: "P30D"
          data_store_type: VaultStore
    - name: weekly
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      default_retention_rule:
        life_cycle:
          duration: "P7D"
          data_store_type: VaultStore

  mysql_instances:
    - name: mysql1-backup
      server_name: my-mysql-server-1
      resource_group_name: my-db-rg
      policy_key: daily

  # DISKS configuration
  disk_policies:
    - name: daily-disk-policy
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      default_retention_duration: "P7D"

  disk_instances:
    - name: disk1-backup
      disk_resource_group: my-disk-rg
      policy_key: daily-disk-policy

  # BLOB configuration
  blob_policies:
    - name: daily
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      operational_default_retention_duration: "P7D"
      vault_default_retention_duration: "P30D"
    - name: weekly
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT10M"
      operational_default_retention_duration: "P30D"
      vault_default_retention_duration: "P90D"

  blob_instances:
    - name: blob1-backup
      storage_account_name: my-storage-account-1
      storage_account_resource_group: my-storage-rg
      storage_account_container_names: ["container1"]
      policy_key: daily
    - name: blob2-backup
      storage_account_name: my-storage-account-2
      storage_account_resource_group: my-storage-rg-2
      storage_account_container_names: ["container2"]
      policy_key: weekly

  # KUBERNETES configuration
  kubernetes_policies:
    - name: daily-k8s-policy
      backup_repeating_time_intervals:
        - "R/2025-10-23T08:00:00Z/PT24H"
      default_retention_rule:
        life_cycle:
          duration: "P30D"
          data_store_type: OperationalStore

  kubernetes_instances:
    - name: k8s1-backup
      cluster_name: my-k8s-cluster-1
      resource_group_name: my-k8s-rg
      snapshot_resource_group_name: my-k8s-snapshots-rg
      policy_key: daily-k8s-policy
      extension_configuration:
        bucket_name: my-bucket
        bucket_resource_group_name: my-storage-rg
        bucket_storage_account_name: my-storage-account-1
```


## Notes

- Each data source type (blob, disk, kubernetes, mysql, postgresql) has its own `*_policies` and `*_instances` variables; configure only the ones you need.
- For Kubernetes backups, the module can create the AKS backup extension and trusted access role binding; provide `extension_configuration` when required.
- Policy keys in instances must match the `name` of a policy in the corresponding policies list.

## File structure

```
.
├── vault.tf
├── blob.tf
├── disk.tf
├── kubernetes.tf
├── mysql.tf
├── postgresql.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
