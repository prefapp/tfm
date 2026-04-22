<!-- BEGIN_TF_DOCS -->
# Azure Storage Account Terraform module (`azure-sa`)

## Overview

This module creates an **Azure Storage Account** in an existing resource group, applies **network rules** (subnets from data sources plus optional extra subnet IDs and private link access), and can provision **blob containers**, **file shares**, **queues**, **tables**, optional **lifecycle management policies**, and **Microsoft Defender for Storage** (advanced threat protection) when enabled.

The module does **not** create the resource group or virtual networks; it looks up the resource group for location/tags and resolves allowed subnets via **`azurerm_subnet`** data sources.

## Key features

- **Storage account**: Tier, replication, kind, TLS, public access, optional managed identity and blob service properties (versioning, retention, restore policy) with validations on common combinations.
- **Network**: `azurerm_storage_account_network_rules` combining subnets from `allowed_subnets`, `additional_allowed_subnet_ids`, optional IP rules, bypass, and private link access entries.
- **Data plane resources**: Optional containers, shares, queues, and tables via `for_each` maps.
- **Outputs**: Storage account `id`, `name`, `primary_blob_endpoint`, and maps of child resource IDs (`container_id`, `share_id`, `queue_id`, `table_id`).
- **Lifecycle**: Optional `azurerm_storage_management_policy` when `lifecycle_policy_rules` is set.
- **Tags**: `tags` map; with `tags_from_rg = true` (default is `false`), resource group tags are merged with `tags`.

## Prerequisites

- Existing **resource group** (`resource_group_name`).
- For **deny-by-default** networking, configure `allowed_subnets` and/or `additional_allowed_subnet_ids` (and/or IP rules) so the account remains reachable for your workloads.
- Storage **account name** must be **globally unique**, 3–24 characters, lowercase letters and numbers only.

## Basic usage

Pass `resource_group_name`, `storage_account`, and `network_rules`. Optional inputs default to empty/`null` where applicable; see the **Inputs** table for full types.

### Minimal example

```hcl
module "storage" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-sa?ref=<version>"

  resource_group_name = "my-resource-group"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  allowed_subnets               = []
  additional_allowed_subnet_ids = []

  storage_account = {
    name                     = "mystorageacctuniq01"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }

  network_rules = {
    default_action = "Allow"
  }
}
```

Use `default_action = "Deny"` only together with subnet/IP/private link rules that match your connectivity model.

## File structure

```
.
├── CHANGELOG.md
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```

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
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where the storage account is created (also used for the data source and optional tag merge). | `string` | n/a | yes |
| <a name="input_shares"></a> [shares](#input\_shares) | Specifies the storage shares | <pre>list(object({<br/>    name             = string<br/>    access_tier      = optional(string)<br/>    enabled_protocol = optional(string)<br/>    quota            = number<br/>    metadata         = optional(map(string))<br/>    acl = optional(list(object({<br/>      id = string<br/>      access_policy = optional(object({<br/>        permissions = string<br/>        start       = optional(string)<br/>        expiry      = optional(string)<br/>      }))<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Configuration for the Azure Storage Account | <pre>object({<br/>    name                             = string<br/>    account_tier                     = string<br/>    account_replication_type         = string<br/>    account_kind                     = optional(string, "StorageV2")<br/>    access_tier                      = optional(string, "Hot")<br/>    cross_tenant_replication_enabled = optional(bool, false)<br/>    edge_zone                        = optional(string)<br/>    allow_nested_items_to_be_public  = optional(bool, true)<br/>    https_traffic_only_enabled       = optional(bool, true)<br/>    min_tls_version                  = optional(string, "TLS1_2")<br/>    public_network_access_enabled    = optional(bool, true)<br/>    threat_protection_enabled        = optional(bool, false)<br/>    tags                             = optional(map(string), {})<br/>    identity = optional(object({<br/>      type         = optional(string, "SystemAssigned")<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    blob_properties = optional(object({<br/>      versioning_enabled  = optional(bool)<br/>      change_feed_enabled = optional(bool)<br/>      last_access_time_enabled = optional(bool)<br/>      delete_retention_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>      container_delete_retention_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>      restore_policy = optional(object({<br/>        days = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tables"></a> [tables](#input\_tables) | Specifies the storage tables | <pre>list(object({<br/>    name = string<br/>    acl = optional(object({<br/>      id = string<br/>      access_policy = optional(object({<br/>        permissions = string<br/>        start       = optional(string)<br/>        expiry      = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Map from each container name (for\_each key) to the blob container resource ID. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the storage account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the storage account. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob service endpoint URL. |
| <a name="output_queue_id"></a> [queue\_id](#output\_queue\_id) | Map from each queue name to the queue resource ID. |
| <a name="output_share_id"></a> [share\_id](#output\_share\_id) | Map from each file share name to the file share resource ID. |
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | Map from each table name to the table resource ID. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/basic) — Minimal storage account with permissive network defaults; set an existing RG and a globally unique storage account name (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/comprehensive) — Reference YAML for containers, queues, tables, shares, lifecycle rules, and stricter networking (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.38.1** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.38.1`).

- **Azure Storage**: [https://learn.microsoft.com/azure/storage/](https://learn.microsoft.com/azure/storage/)
- **azurerm\_storage\_account**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1/docs/resources/storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1/docs/resources/storage_account)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1](https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->