// Basic example: backup vault with PostgreSQL, MySQL, disk, blob and Kubernetes policies

module "azure_backup_vault" {
  source = "../../"

  backup_resource_group_name = "my-backup-rg"

  vault = {
    name               = "my-backup-vault"
    datastore_type     = "VaultStore"
    redundancy         = "LocallyRedundant"
    retention_duration_in_days = 30
    immutability       = "Disabled"
    soft_delete        = "Off"
  }

  postgresql_policies = [
    {
      name                            = "daily"
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
    }
  ]

  postgresql_instances = [
    {
      name                = "pg1-backup"
      server_name         = "my-postgres-server-1"
      resource_group_name = "my-db-rg"
      policy_key          = "daily"
    }
  ]

  disk_policies = [
    {
      name                            = "daily-disk-policy"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_duration      = "P7D"
    }
  ]

  disk_instances = [
    {
      name                = "disk1-backup"
      disk_resource_group = "my-disk-rg"
      policy_key          = "daily-disk-policy"
    }
  ]

  blob_policies = [
    {
      name                                   = "daily"
      backup_repeating_time_intervals        = ["R/2025-10-23T08:00:00Z/PT10M"]
      operational_default_retention_duration = "P7D"
      vault_default_retention_duration       = "P30D"
    }
  ]

  blob_instances = [
    {
      name                           = "blob1-backup"
      storage_account_name           = "my-storage-account-1"
      storage_account_resource_group = "my-storage-rg"
      storage_account_container_names = ["container1"]
      policy_key                     = "daily"
    }
  ]

  kubernetes_policies = [
    {
      name                            = "daily-k8s-policy"
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
      name                         = "k8s1-backup"
      cluster_name                 = "my-k8s-cluster-1"
      resource_group_name          = "my-k8s-rg"
      snapshot_resource_group_name = "my-k8s-snapshots-rg"
      policy_key                   = "daily-k8s-policy"
      extension_configuration = {
        bucket_name                 = "my-bucket"
        bucket_resource_group_name  = "my-storage-rg"
        bucket_storage_account_name = "my-storage-account-1"
      }
    }
  ]

  tags = {
    environment = "dev"
  }
}

