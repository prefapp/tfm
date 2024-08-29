## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container.html) | resource |
| [azurerm_recovery_services_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_backup_container_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) | resource |
| [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The name of the resource group in which the vnet is located | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the virtual subnet | `object(map)` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name to use for this storage account | `string` | n/a | yes |
| <a name="input_storage_account_container_name"></a> [storage\_account\_container\_name](#input\_storage\_account\_container\_name) | The name to use for the container | `list(string)` | n/a | yes |
| <a name="input_storage_account_network_rule_default_action"></a> [storage\_account\_network\_rule\_default\_action](#input\_storage\_account\_network\_rule\_default\_action) | The default action of allow or deny when no other rules match | `string` | n/a | yes |
| <a name="input_storage_account_network_rule_bypass"></a> [storage\_account\_network\_rule\_bypass](#input\_storage\_account\_network\_rule\_bypass) | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices | `string` | n/a | yes |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | The Tier to use for this storage account | `string` | n/a | yes |
| <a name="input_storage_account_kind"></a> [storage\_account\_kind](#input\_storage\_account\_kind) | The Kind of account to create | `string` | n/a | yes |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | The type of replication to use for this storage account | `string` | n/a | yes |
| <a name="input_storage_account_min_tls_version"></a> [storage\_account\_min\_tls\_version](#input\_storage\_account\_min\_tls\_version) | The minimum supported TLS version for the storage account | `string` | n/a | yes |
| <a name="input_storage_account_enable_https_traffic_only"></a> [storage\_account\_enable\_https\_traffic\_only](#input\_storage\_account\_enable\_https\_traffic\_only) | Allows https traffic only to storage service | `bool` | n/a | yes |
| <a name="input_storage_account_cross_tenant_replication_enabled"></a> [storage\_account\_cross\_tenant\_replication\_enabled](#input\_storage\_account\_cross\_tenant\_replication\_enabled) | Allow or disallow cross-tenant replication | `bool` | n/a | yes |
| <a name="input_storage_account_allow_nested_items_to_be_public"></a> [storage\_account\_allow\_nested\_items\_to\_be\_public](#input\_storage\_account\_allow\_nested\_items\_to\_be\_public) | Allow or disallow public access to the nested files and directories | `bool` | n/a | yes |
| <a name="input_threat_protection_enabled"></a> [threat\_protection\_enabled](#input\_threat\_protection\_enabled) | Enable threat protection | `bool` | n/a | yes |
| <a name="input_quota"></a> [quota](#input\_quota) | The maximum size of the share, in gigabytes | `string` | n/a | yes |
| <a name="input_blob_retention_soft_delete"></a> [blob\_retention\_soft\_delete](#input\_blob\_retention\_soft\_delete) | Specifies the number of days that the blob should be retained | `number` | n/a | yes |
| <a name="input_container_retention_soft_delete"></a> [container\_retention\_soft\_delete](#input\_container\_retention\_soft\_delete) | Specifies the number of days that the container should be retained | `number` | n/a | yes |
| <a name="input_recovery_services_vault_name"></a> [recovery\_services\_vault\_name](#input\_recovery\_services\_vault\_name) | Recovery service vault name | `string` | n/a | yes |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the backup policy | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU (Stock Keeping Unit) of the resource | `string` | n/a | yes |
| <a name="input_soft_delete_enabled"></a> [soft\_delete\_enabled](#input\_soft\_delete\_enabled) | Enable soft delete | `bool` | n/a | yes |
| <a name="input_change_feed_enabled"></a> [change\_feed\_enabled](#input\_change\_feed\_enabled) | Specifies whether the change feed is enabled for the storage account | `bool` | n/a | yes |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Specifies whether versioning is enabled for the blobs in the storage account | `bool` | n/a | yes |
| <a name="input_backup_policy"></a> [backup\_policy](#input\_backup\_policy) | A map of backup policies to be created in the Recovery Services Vault | `object(map)` | n/a | yes |
| <a name="input_backup_vault_name"></a> [backup\_vault\_name](#input\_backup\_vault\_name) | The name of the backup vault | `string` | n/a | yes |
| <a name="input_backup_vault_datastore_type"></a> [backup\_vault\_datastore\_type](#input\_backup\_vault\_datastore\_type) | The type of data store for the backup vault | `string` | n/a | yes |
| <a name="input_backup_vault_redundancy"></a> [backup\_vault\_redundancy](#input\_backup\_vault\_redundancy) | The redundancy setting for the backup vault | `string` | n/a | yes |
| <a name="input_backup_vault_identity_type"></a> [backup\_vault\_identity\_type](#input\_backup\_vault\_identity\_type) | The type of identity assigned to the backup vault | `string` | n/a | yes |
| <a name="input_backup_role_assignment"></a> [backup\_role\_assignment](#input\_backup\_role\_assignment) | The role assignment for managing backups | `string` | n/a | yes |
| <a name="input_backup_policy_blob_name"></a> [backup\_policy\_blob\_name](#input\_backup\_policy\_blob\_name) | The name of the blob storing backup policies | `string` | n/a | yes |
| <a name="input_backup_policy_retention_duration"></a> [backup\_policy\_retention\_duration](#input\_backup\_policy\_retention\_duration) | The retention duration for backups | `string` | n/a | yes |
| <a name="input_backup_instance_blob_name"></a> [backup\_instance\_blob\_name](#input\_backup\_instance\_blob\_name) | The name of the blob storing backup instances | `string` | n/a | yes |
| <a name="input_lifecycle_policy_rule"></a> [lifecycle\_policy\_rule](#input\_lifecycle\_policy\_rule) | A list of lifecycle policy rules for managing blobs | `list(object)` | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |

## Example

```yaml
    values:
      # data values
      resource_group_name: "rg_name"
      subnet:
        - name: "subnet0"
          vnet: "vnet1"
          resource_group: "rg_test0"
        - name: "subnet1"
          vnet: "vnet0"
          resource_group: "rgtest1"

      additional_subnet_ids:
        - "/subscriptions/xXx/resourceGroups/xXx/providers/Microsoft.Network/virtualNetworks/xXx/subnets/xXx0"
        - "/subscriptions/xXx/resourceGroups/xXx/providers/Microsoft.Network/virtualNetworks/xXx/subnets/xXx1"

      # storage account values
      storage_account:
        name: "sa_name"
        account_tier: "Standard"
        account_kind: "StorageV2"
        account_replication_type: "LRS"
        min_tls_version: "TLS1_2"
        https_traffic_only_enabled: true
        cross_tenant_replication_enabled: false
        allow_nested_items_to_be_public: false
        versioning_enabled: false
        change_feed_enabled: false
        blob_retention_soft_delete: 7
        container_retention_soft_delete: 7
        default_action: "Deny"
        bypass: "AzureServices"
        tags: {}

      # storage container
      storage_container:
        - name: "test"
          container_access_type: "private"
        - name: "test2"
          container_access_type: "private"

      # storage blob
      storage_blob:
        - name: "test"
          storage_container_name: "test"

      # storage account lifecycle policy values
      lifecycle_policy_rule:
        - name: "lifecycle_policy_purge"
          enabled: true
          filters:
            prefix_match:
              - "blob/"
            blob_types:
              - "blockBlob"
              - "appendBlob"
          actions:
            base_blob:
              delete_after_days_since_creation_greater_than: 365
            snapshot:
              delete_after_days_since_creation_greater_than: 365
            version:
              delete_after_days_since_creation: 365

      # backup shares values
      recovery_services_vault_name: "recovery_vault_name"
      sku: "Standard"
      soft_delete_enabled: true

      # backup blobs values
      backup_vault_name: "storage-backups"
      backup_vault_datastore_type: "VaultStore"
      backup_vault_redundancy: "LocallyRedundant"
      backup_vault_identity_type: "SystemAssigned"
      backup_role_assignment: "Storage Account Backup Contributor"
      backup_policy_blob_name: "storage-backup-policy"
      backup_policy_retention_duration: "P30D"
      backup_instance_blob_name: "storage-backup-instance"
      backup_policy:
        frequency: "Daily"
        time: "02:00"
        retention_daily: 15
        retention_monthly: 2
        retention_yearly: 1

      # tags
      tags:
        cliente: "inss"
        tenant: "inss"
        Producto: "ovac"
        application: "ovac"
        env: "pre"
```
