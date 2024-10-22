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
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share.html) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue.html) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table.html) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [tags](#input_tags) | The tags to associate with your resources | map(string) | n/a | yes |
| [resource_group_name](#input_resource_group_name) | The name for the resource group | string | n/a | yes |
| [allowed_subnets](#input_allowed_subnets) | Subnet values for data | list(object({ name=string, vnet=string, resource_group=string })) | n/a | yes |
| [additional_allowed_subnet_ids](#input_additional_allowed_subnet_ids) | Additional subnets id for storage account network rules | list(string) | n/a | no |
| [storage_account](#input_storage_account) | Configuration for the Azure Storage Account | object({ name=string, account_tier=string, account_replication_type=string, account_kind=optional(string, "StorageV2"), access_tier=optional(string, "Hot"), cross_tenant_replication_enabled=optional(bool, false), edge_zone=optional(string), allow_nested_items_to_be_public=optional(bool, true), https_traffic_only_enabled=optional(bool, true), min_tls_version=optional(string, "TLS1_2"), public_network_access_enabled=optional(bool, true), threat_protection_enabled=optional(bool, false), identity=optional(object({ type=optional(string, "SystemAssigned"), identity_ids=optional(list(string), []) })), blob_properties=optional(object({ versioning_enabled=optional(bool), change_feed_enabled=optional(bool), delete_retention_policy=optional(object({ days=optional(number) })), container_delete_retention_policy=optional(object({ days=optional(number) }), restore_policy=optional(object({ days=optional(number) }) ) })), tags=optional(map(string), {}) }) | n/a | yes |
| [network_rules](#input_network_rules) | Network rules for the storage account | object({ default_action=string, bypass=optional(string, "AzureServices"), ip_rules=optional(list(string)), private_link_access=optional(list(object({ endpoint_resource_id=string, endpoint_tenant_id=optional(string) }))) }) | n/a | yes |
| [containers](#input_containers) | Specifies the storage containers | list(object({ name=string, container_access_type=optional(string), default_encryption_scope=optional(string), encryption_scope_override_enabled=optional(bool), metadata=optional(map(string)) })) | null | no |
| [shares](#input_shares) | Specifies the storage shares | list(object({ name=string, access_tier=optional(string), enabled_protocol=optional(string), quota=number, metadata=optional(map(string)), acl=optional(list(object({ id=string, access_policy=optional(object({ permissions=string, start=optional(string), expiry=optional(string) })) }))) })) | null | no |
| [queues](#input_queues) | Specifies the storage queues | list(object({ name=string, metadata=optional(map(string)) })) | null | no |
| [tables](#input_tables) | Specifies the storage tables | list(object({ name=string, acl=optional(object({ id=string, access_policy=optional(object({ permissions=string, start=optional(string), expiry=optional(string) })) })) })) | null | no |
| [lifecycle_policy_rules](#input_lifecycle_policy_rules) | List of lifecycle management rules for the Azure Storage Account | list(object({ name=string, enabled=bool, filters=object({ blob_types=list(string), prefix_match=optional(list(string)), match_blob_index_tag=optional(list(object({ name=string, operation=optional(string, "=="), value=string })), []) }), actions=object({ base_blob=optional(object({ tier_to_cool_after_days_since_modification_greater_than=optional(number), tier_to_cool_after_days_since_last_access_time_greater_than=optional(number), tier_to_cool_after_days_since_creation_greater_than=optional(number), auto_tier_to_hot_from_cool_enabled=optional(bool, false), tier_to_archive_after_days_since_modification_greater_than=optional(number), tier_to_archive_after_days_since_last_access_time_greater_than=optional(number), tier_to_archive_after_days_since_creation_greater_than=optional(number), delete_after_days_since_modification_greater_than=optional(number), delete_after_days_since_last_access_time_greater_than=optional(number), delete_after_days_since_creation_greater_than=optional(number) }), {}), snapshot=optional(object({ change_tier_to_archive_after_days_since_creation=optional(number), tier_to_archive_after_days_since_last_tier_change_greater_than=optional(number), change_tier_to_cool_after_days_since_creation=optional(number), tier_to_cold_after_days_since_creation_greater_than=optional(number), delete_after_days_since_creation_greater_than=optional(number) }), {}), version=optional(object({ change_tier_to_archive_after_days_since_creation=optional(number), tier_to_archive_after_days_since_last_tier_change_greater_than=optional(number), change_tier_to_cool_after_days_since_creation=optional(number), tier_to_cold_after_days_since_creation_greater_than=optional(number), delete_after_days_since_creation=optional(number) }), {}) }) })) | null | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the storage account |

## Example

```yaml
    values:
      # data values
      resource_group_name: "rg_test"
      allowed_subnets:
        - name: "data"
          vnet: "test-vnet"
          resource_group: "rg-test"
        - name: "video"
          vnet: "test-vnet1"
          resource_group: "rg-test1"
      additional_allowed_subnet_ids:
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
        public_network_access_enabled: true
        identity:
          type: "SystemAssigned"
        blob_properties:
          versioning_enabled: true
          change_feed_enabled: true
          delete_retention_policy:
            days: 30
          container_delete_retention_policy:
            days: 15
          restore_policy:
            days: 10

      # storage account network rules
      network_rules:
        default_action: "Deny"
        bypass: "AzureServices"
        private_link_access:
          - endpoint_resource_id: "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/privateLinkService/xxxx"
            endpoint_tenant_id: "66666666-7777-8888-9999-000000000000"
          - endpoint_resource_id: "/subscriptions/yyyy/resourceGroups/yyyy/providers/Microsoft.Network/privateLinkService/yyyy"

      # storage containers
      containers:
        - name: "test"
          container_access_type: "private"
        - name: "test2"
          container_access_type: "private"

      # storage queues
      queues:
        - name: "test"
          metadata:
            queuename: functionsqueue
            queuelength: '5'
            connection: STORAGE_CONNECTIONSTRING_ENV_NAME

      # storage tables
      tables:
        - name: "Table1"
          acl:
            id: "policy1"
            access_policy:
              permissions: "rwd"
              start: "2024-09-01T00:00:00Z"
              expiry: "2024-09-30T23:59:59Z"

      # storage shares
      shares:
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

      # storage management policy rules
      lifecycle_policy_rules:
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
