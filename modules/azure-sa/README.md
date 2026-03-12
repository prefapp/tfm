## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.38.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.38.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_advanced_threat_protection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/advanced_threat_protection) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_allowed_subnet_ids"></a> [additional\_allowed\_subnet\_ids](#input\_additional\_allowed\_subnet\_ids) | Additional subnets id for storage account network rules | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | Subnet values for data | <pre>list(object({<br/>    name           = string<br/>    vnet           = string<br/>    resource_group = string<br/>  }))</pre> | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Specifies the storage containers | <pre>list(object({<br/>    name                              = string<br/>    container_access_type             = optional(string)<br/>    default_encryption_scope          = optional(string)<br/>    encryption_scope_override_enabled = optional(bool)<br/>    metadata                          = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_lifecycle_policy_rules"></a> [lifecycle\_policy\_rules](#input\_lifecycle\_policy\_rules) | List of lifecycle management rules for the Azure Storage Account | <pre>list(object({<br/>    name    = string<br/>    enabled = bool<br/>    filters = object({<br/>      blob_types   = list(string)<br/>      prefix_match = optional(list(string))<br/><br/>      match_blob_index_tag = optional(list(object({<br/>        name      = string<br/>        operation = optional(string, "==")<br/>        value     = string<br/>      })), [])<br/>    })<br/>    actions = object({<br/>      base_blob = optional(object({<br/>        tier_to_cool_after_days_since_modification_greater_than        = optional(number)<br/>        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)<br/>        tier_to_cool_after_days_since_creation_greater_than            = optional(number)<br/>        auto_tier_to_hot_from_cool_enabled                             = optional(bool, false)<br/>        tier_to_archive_after_days_since_modification_greater_than     = optional(number)<br/>        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)<br/>        tier_to_archive_after_days_since_creation_greater_than         = optional(number)<br/>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)<br/>        tier_to_cold_after_days_since_modification_greater_than        = optional(number)<br/>        tier_to_cold_after_days_since_last_access_time_greater_than    = optional(number)<br/>        tier_to_cold_after_days_since_creation_greater_than            = optional(number)<br/>        delete_after_days_since_modification_greater_than              = optional(number)<br/>        delete_after_days_since_last_access_time_greater_than          = optional(number)<br/>        delete_after_days_since_creation_greater_than                  = optional(number)<br/>      }), {})<br/>      snapshot = optional(object({<br/>        change_tier_to_archive_after_days_since_creation               = optional(number)<br/>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)<br/>        change_tier_to_cool_after_days_since_creation                  = optional(number)<br/>        tier_to_cold_after_days_since_creation_greater_than            = optional(number)<br/>        delete_after_days_since_creation_greater_than                  = optional(number)<br/>      }), {})<br/>      version = optional(object({<br/>        change_tier_to_archive_after_days_since_creation               = optional(number)<br/>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)<br/>        change_tier_to_cool_after_days_since_creation                  = optional(number)<br/>        tier_to_cold_after_days_since_creation_greater_than            = optional(number)<br/>        delete_after_days_since_creation                               = optional(number)<br/>      }), {})<br/>    })<br/>  }))</pre> | `null` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules for the storage account | <pre>object({<br/>    default_action = string<br/>    bypass         = optional(string, "AzureServices")<br/>    ip_rules       = optional(list(string))<br/>    private_link_access = optional(list(object({<br/>      endpoint_resource_id = string<br/>      endpoint_tenant_id   = optional(string)<br/>    })))<br/>  })</pre> | n/a | yes |
| <a name="input_queues"></a> [queues](#input\_queues) | Specifies the storage queues | <pre>list(object({<br/>    name     = string<br/>    metadata = optional(map(string))<br/>  }))</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name for the resource group | `string` | n/a | yes |
| <a name="input_shares"></a> [shares](#input\_shares) | Specifies the storage shares | <pre>list(object({<br/>    name             = string<br/>    access_tier      = optional(string)<br/>    enabled_protocol = optional(string)<br/>    quota            = number<br/>    metadata         = optional(map(string))<br/>    acl = optional(list(object({<br/>      id = string<br/>      access_policy = optional(object({<br/>        permissions = string<br/>        start       = optional(string)<br/>        expiry      = optional(string)<br/>      }))<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Configuration for the Azure Storage Account | <pre>object({<br/>    name                             = string<br/>    account_tier                     = string<br/>    account_replication_type         = string<br/>    account_kind                     = optional(string, "StorageV2")<br/>    access_tier                      = optional(string, "Hot")<br/>    cross_tenant_replication_enabled = optional(bool, false)<br/>    edge_zone                        = optional(string)<br/>    allow_nested_items_to_be_public  = optional(bool, true)<br/>    https_traffic_only_enabled       = optional(bool, true)<br/>    min_tls_version                  = optional(string, "TLS1_2")<br/>    public_network_access_enabled    = optional(bool, true)<br/>    threat_protection_enabled        = optional(bool, false)<br/>    tags                             = optional(map(string), {})<br/>    identity = optional(object({<br/>      type         = optional(string, "SystemAssigned")<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    blob_properties = optional(object({<br/>      versioning_enabled  = optional(bool)<br/>      change_feed_enabled = optional(bool)<br/>      last_access_time_enabled = optional(bool)<br/>      delete_retention_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>      container_delete_retention_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>      restore_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tables"></a> [tables](#input\_tables) | Specifies the storage tables | <pre>list(object({<br/>    name = string<br/>    acl = optional(object({<br/>      id = string<br/>      access_policy = optional(object({<br/>        permissions = string<br/>        start       = optional(string)<br/>        expiry      = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

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
