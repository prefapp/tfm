# **Azure Data Protection Backup Vault Terraform Module**

## Overview

This module provisions and manages an Azure Data Protection Backup Vault and related backup resources for disks, blobs, Kubernetes clusters, PostgreSQL, and MySQL Flexible (not stable at the moment) Servers. It supports flexible policy and instance configuration for each resource type, enabling centralized and automated backup management in Azure.

It is suitable for production, staging, and development environments, and can be easily integrated into larger Terraform projects or used standalone.

## Key Features

- **Comprehensive Backup Management**: Supports backup for Azure disks, blob storage, Kubernetes clusters, PostgreSQL, and MySQL Flexible Servers.
- **Flexible Policy Configuration**: Define custom backup policies for each resource type, including retention, schedules, and lifecycle rules.
- **Multiple Instance Support**: Manage multiple backup instances for each supported resource in a single module invocation.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Role Assignments**: Automatically assigns required roles for backup operations.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure infrastructure modules.

## Basic Usage

See the main README and the `_examples/` directory for usage examples for each supported resource type.

```hcl
module "azure_backup_vault" {
  source = "../../"

  # COMMON configuration
  backup_resource_group_name = "my-backup-rg"

  # VAULT configuration
  vault = {
    name                       = "my-backup-vault"
    location                   = "eastus"
    datastore_type             = "VaultStore"
    redundancy                 = "LocallyRedundant"
    retention_duration_in_days = 30
    immutability               = "Disabled"
    soft_delete                = "Off"
  }

  # POSTGRESQL configuration
  postgresql_policies = [
    {
      name = "daily"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name     = "daily"
          priority = 1
          life_cycle = {
            duration        = "P7D"
            data_store_type = "VaultStore"
          }
          criteria = {
            absolute_criteria = "FirstOfDay"
          }
        }
      ]
    },
    {
      name = "weekly"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name     = "weekly"
          priority = 1
          life_cycle = {
            duration        = "P30D"
            data_store_type = "VaultStore"
          }
          criteria = {
            absolute_criteria = "FirstOfDay"
          }
        }
      ]
    }
  ]

  postgresql_instances = [
    {
      name                = "pg1-backup"
      location            = "eastus"
      server_name         = "my-postgres-server-1"
      resource_group_name = "my-db-rg"
      policy_key          = "daily"
    },
    {
      name                = "pg2-backup"
      location            = "eastus"
      server_name         = "my-postgres-server-2"
      resource_group_name = "my-db-rg-2"
      policy_key          = "weekly"
    }
  ]

  # MYSQL configuration (disabled by Azure for now)
  mysql_policies = [
    {
      name = "daily"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
    },
    {
      name = "weekly"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P7D"
          data_store_type = "VaultStore"
        }
      }
    }
  ]

  mysql_instances = [
    {
      name                = "mysql1-backup"
      location            = "eastus"
      server_name         = "my-mysql-server-1"
      resource_group_name = "my-db-rg"
      policy_key          = "daily"
    }
  ]

  # DISKS configuration
  disk_policies = [
    {
      name = "daily-disk-policy"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_duration      = "P7D"
    }
  ]

  disk_instances = [
    {
      name                = "disk1-backup"
      location            = "eastus"
      disk_resource_group = "my-disk-rg"
      policy_key          = "daily-disk-policy"
    }
  ]

  # BLOB configuration
  blob_policies = [
    {
      name                                 = "daily"
      backup_repeating_time_intervals      = ["R/2025-10-23T08:00:00Z/PT10M"]
      operational_default_retention_duration = "P7D"
      vault_default_retention_duration     = "P30D"
    },
    {
      name                                 = "weekly"
      backup_repeating_time_intervals      = ["R/2025-10-23T08:00:00Z/PT10M"]
      operational_default_retention_duration = "P30D"
      vault_default_retention_duration     = "P90D"
    }
  ]

  blob_instances = [
    {
      name                          = "blob1-backup"
      location                      = "eastus"
      storage_account_name          = "my-storage-account-1"
      storage_account_resource_group = "my-storage-rg"
      storage_account_container_names = ["container1"]
      policy_key                    = "daily"
    },
    {
      name                          = "blob2-backup"
      location                      = "eastus"
      storage_account_name          = "my-storage-account-2"
      storage_account_resource_group = "my-storage-rg-2"
      storage_account_container_names = ["container2"]
      policy_key                    = "weekly"
    }
  ]

  # KUBERNETES configuration
  kubernetes_policies = [
    {
      name = "daily-k8s-policy"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT24H"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "OperationalStore"
        }
      }
    }
  ]

  kubernetes_instances = [
    {
      name                        = "k8s1-backup"
      location                    = "eastus"
      cluster_name                = "my-k8s-cluster-1"
      resource_group_name         = "my-k8s-rg"
      snapshot_resource_group_name = "my-k8s-snapshots-rg"
      policy_key                  = "daily-k8s-policy"
      extension_configuration = {
        bucket_name                 = "my-bucket"
        bucket_resource_group_name  = "my-storage-rg"
        bucket_storage_account_name = "my-storage-account-1"
      }
    }
  ]
}
```
