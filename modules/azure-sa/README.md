<!-- BEGIN_TF_DOCS -->
# Azure Storage Account Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Storage Account, including:
- Advanced account configuration (tier, replication, network, TLS, etc.)
- Support for blobs, queues, tables, and shares
- Lifecycle policies and network rules
- Integration with subnets and advanced threat protection
- Flexible tagging and inheritance from the Resource Group

## Main features
- Create Storage Account with advanced configuration
- Support for containers, queues, tables, and shares
- Customizable lifecycle policies and network rules
- Integration with subnets and advanced protection
- Tag management and inheritance from Resource Group

## Requirements
- Terraform >= 1.7.0
- Provider azurerm ~> 4.38.1

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── header.md
│   └── footer.md
└── _examples/
    ├── basic/
    │   └── main.tf
    └── complete/
        ├── main.tf
        └── values.yaml
```

## Basic usage example

```yaml
values:
  resource_group_name: "rg_test"
  storage_account:
    name: "mystorageaccount"
    account_tier: "Standard"
    account_replication_type: "LRS"
```

> For a complete and advanced example, see the file at `_examples/complete/values.yaml`.

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
| <a name="output_id"></a> [id](#output\_id) | ID of the created Storage Account. |

---

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/basic) - Minimal Storage Account configuration with containers, queues, tables and shares.
- [complete](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/complete) - Full example including network rules, lifecycle policies and multiple data services.

## Additional resources

- [Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [Official Terraform documentation](https://www.terraform.io/docs)

## Support
For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->