# Example: Configure PostgreSQL backup with custom policies

module "azure_backup_vault" {
  source = "../../"

  backup_resource_group_name = "my-backup-rg"
  vault = {
    name           = "my-backup-vault"
    datastore_type = "VaultStore"
    redundancy     = "LocallyRedundant"
    retention_duration_in_days = 30
    immutability = "Disabled"
    soft_delete = "Off"
  }

  postgresql_policies = [
    {
      name = "daily"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name = "daily"
          priority = 1
          life_cycle = {
            duration = "P7D"
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
          duration = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name = "weekly"
          priority = 1
          life_cycle = {
            duration = "P30D"
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
      name = "pg1-backup"
      server_name = "my-postgres-server-1"
      resource_group_name = "my-db-rg"
      policy_key = "daily"
    },
    {
      name = "pg2-backup"
      server_name = "my-postgres-server-2"
      resource_group_name = "my-db-rg-2"
      policy_key = "weekly"
    }
  ]
}
