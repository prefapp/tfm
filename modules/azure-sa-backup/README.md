## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group) | data source |
| [azurerm_recovery_services_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_backup_container_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_backup_policy_file_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share) | resource |
| [azurerm_backup_protected_file_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) | resource |
| [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_resource_group_name"></a> [backup\_resource\_group\_name](#input\_backup\_resource\_group\_name) | The name for the resource group for the backups | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | The ID of the storage account | `string` | n/a | yes |
| <a name="input_backup_share"></a> [backup\_share](#input\_backup\_share) | Specifies the backup configuration for the storage share | `object({ policy_name = string, recovery_services_vault_name = string, sku = string, soft_delete_enabled = optional(bool), storage_mode_type = optional(string, "GeoRedundant"), cross_region_restore_enabled = optional(bool), source_file_share_name = list(string), identity = optional(object({ type = optional(string, "SystemAssigned"), identity_ids = optional(list(string), []) })), encryption = optional(object({ key_id = optional(string, null), infrastructure_encryption_enabled = optional(bool, false), user_assigned_identity_id = optional(string, null), use_system_assigned_identity = optional(bool, false) })), timezone = optional(string), backup = object({ frequency = string, time = string }), retention_daily = object({ count = number }), retention_weekly = optional(object({ count = number, weekdays = optional(list(string), ["Sunday"]) })), retention_monthly = optional(object({ count = number, weekdays = optional(list(string), ["Sunday"]), weeks = optional(list(string), ["First"]), days = optional(list(number)) })), retention_yearly = optional(object({ count = number, months = optional(list(string), ["January"]), weekdays = optional(list(string), ["Sunday"]), weeks = optional(list(string), ["First"]), days = optional(list(number)) })) })` | null | no |
| <a name="input_backup_blob"></a> [backup\_blob](#input\_backup\_blob) | Specifies the backup configuration for the storage blob | `object({ vault_name = string, datastore_type = string, redundancy = string, identity_type = optional(string), role_assignment = string, instance_blob_name = string, storage_account_container_names = optional(list(string)), policy = object({ name = string, backup_repeating_time_intervals = optional(list(string)), operational_default_retention_duration = optional(string), retention_rule = optional(list(object({ name = string, duration = string, criteria = object({ absolute_criteria = optional(string), days_of_month = optional(list(number)), days_of_week = optional(list(string)), months_of_year = optional(list(string)), scheduled_backup_times = optional(list(string)), weeks_of_month = optional(list(string)) }), life_cycle = object({ data_store_type = string, duration = string }), priority = number }))), time_zone = optional(string), vault_default_retention_duration = optional(string), retention_duration = optional(string) }) })` | null | no |
| <a name="input_lifecycle_policy_rule"></a> [lifecycle\_policy\_rule](#input\_lifecycle\_policy\_rule) | Specifies the lifecycle policy rule for the storage account | `list(object({ name = string, enabled = bool, filters = object({ prefix_match = list(string), blob_types = list(string) }), actions = object({ base_blob = object({ delete_after_days_since_creation_greater_than = number }), snapshot = object({ delete_after_days_since_creation_greater_than = number }), version = object({ delete_after_days_since_creation = number }) }) }))` | null | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="none"></a> [none](#none) | n/a |

## Example

```yaml
    values:
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
