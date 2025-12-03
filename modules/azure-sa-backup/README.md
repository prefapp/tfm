## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.6.0 |

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
| <a name="input_tags_from_rg"></a> [tags\_from\_rg


## Outputs

No outputs.

## Example

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
