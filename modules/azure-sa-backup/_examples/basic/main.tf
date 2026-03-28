// Basic example: configure backup for Azure Storage Account (file shares + blobs)

module "azure_sa_backup" {
  source = "../../"

  backup_resource_group_name = "example-backup-rg"
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplestorage"

  backup_share = {
    policy_name                  = "daily-backup-policy"
    recovery_services_vault_name = "example-backup-vault"
    sku                          = "Standard"
    soft_delete_enabled          = true
    storage_mode_type            = "GeoRedundant"
    cross_region_restore_enabled = true
    source_file_share_name       = ["datadir"]
    timezone                     = "UTC"
    backup = {
      frequency = "Daily"
      time      = "02:00"
    }
    retention_daily = {
      count = 7
    }
  }

  backup_blob = {
    vault_name                      = "example-backup-vault"
    datastore_type                  = "AzureBlob"
    redundancy                      = "GeoRedundant"
    role_assignment                 = "Storage Blob Data Reader"
    instance_blob_name              = "datadir"
    storage_account_container_names = ["blob1"]
    policy = {
      name                                   = "blob-policy"
      backup_repeating_time_intervals        = ["R/2024-09-01T02:00:00+00:00/P1D"]
      operational_default_retention_duration = "P7D"
      retention_rule                         = []
      time_zone                              = "UTC"
      vault_default_retention_duration       = "P30D"
      retention_duration                     = "P30D"
    }
  }

  lifecycle_policy_rule = []

  tags = {
    environment = "dev"
  }
}
