# Example: Configure disk backup with custom policy

module "azure_backup_vault" {
  source = "../../"

  backup_resource_group_name = "example-backup-rg"
  vault = {
    name           = "example-backup-vault"
    location       = "eastus"
    datastore_type = "VaultStore"
    redundancy     = "LocallyRedundant"
  }

  disk_policies = [
    {
      name = "daily-disk-policy"
      backup_repeating_time_intervals = ["R/2026-02-10T08:00:00Z/PT24H"]
      default_retention_duration = "P7D"
    }
  ]

  disk_instances = [
    {
      name = "disk1-backup"
      location = "eastus"
      disk_resource_group = "example-disk-rg"
      policy_key = "daily-disk-policy"
    }
  ]
}
