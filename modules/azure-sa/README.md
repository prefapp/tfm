## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container.html) | resource |
| [azurerm_storage_blob.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob.html) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share.html) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue.html) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table.html) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [tags](#input_tags) | The tags to associate with your resources | map( string ) | n/a | yes |
| [resource_group_name](#input_resource_group_name) | The name for the resource group | string | n/a | yes |
| [subnet](#input_subnet) | Subnet values for data | list( object({ <br>name=string, <br>vnet=string, <br>resource_group=string<br>})) | n/a | yes |
| [additional_subnet_ids](#input_additional_subnet_ids) | Additional subnets id for storage account network rules | list( string ) | n/a | no |
| [storage_account](#input_storage_account) | Configuration for the Azure Storage Account | object({<br>name=string, <br>account_tier=string, <br>account_replication_type=string, <br>account_kind=optional(string, "StorageV2"), <br>access_tier=optional(string, "Hot"), <br>cross_tenant_replication_enabled=optional(bool, false), <br>edge_zone=optional(string), <br>allow_nested_items_to_be_public=optional(bool, true), <br>https_traffic_only_enabled=optional(bool, true), <br>min_tls_version=optional(string, "TLS1_2"), <br>public_network_access_enabled=optional(bool, true), <br>identity=optional(object({<br>&nbsp;&nbsp;type=optional(string, "SystemAssigned"), <br>&nbsp;&nbsp;identity_ids=optional(list(string),[])})), <br>tags=optional(map(string),{}) <br>}) | n/a | yes |
| [storage_account_network_rules](#input_storage_account_network_rules) | Network rules for the storage account | object({<br>default_action=string, <br>bypass=optional(string, "AzureServices"), <br>ip_rules=optional(list(string)), <br>private_link_access=optional(list(object({<br>&nbsp;&nbsp;endpoint_resource_id=string, <br>&nbsp;&nbsp;endpoint_tenant_id=optional(string)}))) <br>}) | n/a | yes |
| [storage_container](#input_storage_container) | Specifies the storage containers | list( object({ <br>name=string, <br>container_access_type=optional(string), <br>default_encryption_scope=optional(string), <br>encryption_scope_override_enabled=optional(bool), <br>metadata=optional(map(string)) <br>})) | n/a | no |
| [storage_share](#input_storage_share) | Specifies the storage shares | list( object({<br>name=string, <br>access_tier=optional(string), <br>enabled_protocol=optional(string), <br>quota=number, <br>metadata=optional(map(string)), <br>acl=optional(list(object({<br>&nbsp;&nbsp;id=string, <br>&nbsp;&nbsp;access_policy=optional(object({<br>&nbsp;&nbsp;&nbsp;&nbsp;permissions=string, <br>&nbsp;&nbsp;&nbsp;&nbsp;start=optional(string), <br>&nbsp;&nbsp;&nbsp;&nbsp;expiry=optional(string)}))}))) <br>})) | n/a | no |
| [storage_blob](#input_storage_blob) | Specifies the storage blobs | list( object({<br>name=string, <br>storage_container_name=string, <br>type=string, <br>source=optional(string), <br>size=optional(number), <br>cache_control=optional(string), <br>content_type=optional(string), <br>content_md5=optional(string), <br>access_tier=optional(string), <br>encryption_scope=optional(string), <br>source_content=optional(string), <br>source_uri=optional(string), <br>parallelism=optional(number), <br>metadata=optional(map(string)) <br>})) | n/a | no |
| [storage_queue](#input_storage_queue) | Specifies the storage queues | list( object({<br>name=string, <br>metadata=optional(map(string)) <br>})) | n/a | no |
| [storage_table](#input_storage_table) | Specifies the storage tables | list( object({<br>name=string, <br>acl=optional(object({<br>&nbsp;&nbsp;id=string, <br>&nbsp;&nbsp;access_policy=optional(object({<br>&nbsp;&nbsp;&nbsp;&nbsp;permissions=string, <br>&nbsp;&nbsp;&nbsp;&nbsp;start=optional(string), <br>&nbsp;&nbsp;&nbsp;&nbsp;expiry=optional(string)}))})) <br>})) | n/a | no |
| [lifecycle_policy_rule](#input_lifecycle_policy_rule) | List of lifecycle management rules for the Azure Storage Account | list( object({<br>name=string, <br>enabled=bool, <br>filters=object( <br>blob_types=list(string), <br>prefix_match=optional(list(string)), <br>match_blob_index_tag=optional(list(object({<br>&nbsp;&nbsp;name=string, <br>&nbsp;&nbsp;operation=optional(string,"=="), <br>&nbsp;&nbsp;value=string})),[])), <br>actions=object( <br>base_blob=optional(object({<br>&nbsp;&nbsp;tier_to_cool_after_days_since_modification_greater_than=optional(number), <br>&nbsp;&nbsp;tier_to_cool_after_days_since_last_access_time_greater_than=optional(number), <br>&nbsp;&nbsp;tier_to_cool_after_days_since_creation_greater_than=optional(number), <br>&nbsp;&nbsp;auto_tier_to_hot_from_cool_enabled=optional(bool,false), <br>&nbsp;&nbsp;tier_to_archive_after_days_since_modification_greater_than=optional(number), <br>&nbsp;&nbsp;tier_to_archive_after_days_since_last_access_time_greater_than=optional(number), <br>&nbsp;&nbsp;tier_to_archive_after_days_since_creation_greater_than=optional(number), <br>&nbsp;&nbsp;delete_after_days_since_modification_greater_than=optional(number), <br>&nbsp;&nbsp;delete_after_days_since_last_access_time_greater_than=optional(number),<br>&nbsp;&nbsp;delete_after_days_since_creation_greater_than=optional(number)}),{}), <br>snapshot=optional(object({<br>&nbsp;&nbsp;change_tier_to_archive_after_days_since_creation=optional(number), <br>&nbsp;&nbsp;tier_to_archive_after_days_since_last_tier_change_greater_than=optional(number), <br>&nbsp;&nbsp;change_tier_to_cool_after_days_since_creation=optional(number), <br>&nbsp;&nbsp;tier_to_cold_after_days_since_creation_greater_than=optional(number), <br>&nbsp;&nbsp;delete_after_days_since_creation_greater_than=optional(number)}),{}), <br>version=optional(object({<br>&nbsp;&nbsp;change_tier_to_archive_after_days_since_creation=optional(number), <br>&nbsp;&nbsp;tier_to_archive_after_days_since_last_tier_change_greater_than=optional(number), <br>&nbsp;&nbsp;change_tier_to_cool_after_days_since_creation=optional(number), <br>&nbsp;&nbsp;tier_to_cold_after_days_since_creation_greater_than=optional(number), <br>&nbsp;&nbsp;delete_after_days_since_creation=optional(number)}),{}) <br>}) | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |

## Example

```yaml
    values:
      # data values
      resource_group_name: "rg_test"
      subnet:
        - name: "data"
          vnet: "test-vnet"
          resource_group: "rg-test"
        - name: "video"
          vnet: "test-vnet1"
          resource_group: "rg-test1"
      additional_subnet_ids:
        - "/subscriptions/324ca80b-cea7-41ff-ac13-25441f452f33/resourceGroups/rg_test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
        - "/subscriptions/c9e99a2d-e0cd-473b-935c-bc2e37ea8511/resourceGroups/rg_test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet1"

      # storage account
      storage_account:
        name: "mystorageaccount"
        account_tier: "Standard"
        account_replication_type: "LRS"
        account_kind: "StorageV2"
        access_tier: "Hot"
        cross_tenant_replication_enabled: false
        https_traffic_only_enabled: true
        min_tls_version: "TLS1_2"
        identity:
          type: "SystemAssigned"

      # storage account network rules
      storage_account_network_rules:
        default_action: "Deny"
        bypass: "AzureServices"
        private_link_access:
          - endpoint_resource_id: "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/privateLinkService/xxxx"
            endpoint_tenant_id: "66666666-7777-8888-9999-000000000000"
          - endpoint_resource_id: "/subscriptions/yyyy/resourceGroups/yyyy/providers/Microsoft.Network/privateLinkService/yyyy"

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
          type: "Block"
          source: "some-local-file.zip"
          size: 512
          access_tier: "Hot"
        - name: "test2"
          storage_container_name: "test"
          type: "Block"
          source: "some-local-file.zip"
          size: 512
          access_tier: "Hot"
        - name: "test"
          storage_container_name: "test2"
          type: "Block"
          source: "some-local-file.zip"
          size: 512
          access_tier: "Hot"

      # storage queue
      storage_queue:
        - name: "test"
          metadata:
            queuename: functionsqueue
            queuelength: '5'
            connection: STORAGE_CONNECTIONSTRING_ENV_NAME

      # storage table
      storage_table:
        - name: "Table1"
          acl:
            id: "policy1"
            access_policy:
              permissions: "rwd"
              start: "2024-09-01T00:00:00Z"
              expiry: "2024-09-30T23:59:59Z"

      # storage share
      storage_share:
        - name: "share1"
          access_tier: "Hot"
          enabled_protocol: "SMB"
          quota: 100
          metadata:
            environment: "production"
            owner: "teamA"
        - name: "share2"
          quota: 200
          metadata:
            environment: "staging"
          acl:
            - id: "policy2"
              access_policy:
                permissions: "r"
                start: "2024-10-01T00:00:00Z"
                expiry: "2024-10-31T23:59:59Z"
        - name: "share3"
          access_tier: "Cool"
          quota: 50

      # storage management policy
      lifecycle_policy_rule:
        - name: "rule1"
          enabled: true
          filters:
            blob_types: 
              - "blockBlob"
            prefix_match: 
              - "container1/prefix1"
            match_blob_index_tag:
              - name: "tag1"
                operation: "=="
                value: "val1"
          actions:
            base_blob:
              tier_to_cool_after_days_since_modification_greater_than: 10
              tier_to_archive_after_days_since_modification_greater_than: 50
              delete_after_days_since_modification_greater_than: 100
            snapshot:
              delete_after_days_since_creation_greater_than: 30
            version:
              delete_after_days_since_creation: 90
        - name: "rule2"
          enabled: false
          filters:
            blob_types: 
              - "blockBlob"
            prefix_match:
              - "container2/prefix1"
              - "container2/prefix2"
          actions:
            base_blob:
              tier_to_cool_after_days_since_modification_greater_than: 11
              tier_to_archive_after_days_since_modification_greater_than: 51
              delete_after_days_since_modification_greater_than: 101
            snapshot:
              change_tier_to_cool_after_days_since_creation: 23
              change_tier_to_archive_after_days_since_creation: 90
              delete_after_days_since_creation_greater_than: 31
            version:
              change_tier_to_archive_after_days_since_creation: 9
              change_tier_to_cool_after_days_since_creation: 90
              delete_after_days_since_creation: 3
      # tags
      tags:
        cliente: "test"
        tenant: "test"
        Producto: "test"
        application: "test"
        env: "test"
```
