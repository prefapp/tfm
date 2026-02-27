<!-- BEGIN_TF_DOCS -->
# **Azure Data Protection Backup Vault Terraform Module**

## Overview

This module provisions and manages an Azure Data Protection Backup Vault and related backup resources for disks, blobs, Kubernetes clusters, PostgreSQL, and MySQL Flexible (not stable at the moment) Servers. It supports flexible policy and instance configuration for each resource type, enabling centralized and automated backup management in Azure.

It is suitable for production, staging, and development environments, and can be easily integrated into larger Terraform projects or used standalone.

## Key Features

- **Comprehensive Backup Management**: Supports backup for Azure disks, blob storage, Kubernetes clusters, PostgreSQL, and MySQL Flexible Servers.
- **Flexible Policy Configuration**: Define custom backup policies for each resource type, including retention, schedules, and lifecycle rules.
- **Multiple Instance Support**: Manage multiple backup instances for each supported resource in a single module invocation.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Role Assignments**: Automatically assigns required roles for backup operations.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure infrastructure modules.

## Basic Usage

See the main README and the `_examples/` directory for usage examples for each supported resource type.

```hcl
module "azure_backup_vault" {
  source = "../../"

  # COMMON configuration
  backup_resource_group_name = "my-backup-rg"

  # VAULT configuration
  vault = {
    name                       = "my-backup-vault"
    location                   = "eastus"
    datastore_type             = "VaultStore"
    redundancy                 = "LocallyRedundant"
    retention_duration_in_days = 30
    immutability               = "Disabled"
    soft_delete                = "Off"
  }

  # POSTGRESQL configuration
  postgresql_policies = [
    {
      name = "daily"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name     = "daily"
          priority = 1
          life_cycle = {
            duration        = "P7D"
            data_store_type = "VaultStore"
          }
          criteria = {
            absolute_criteria = "FirstOfDay"
          }
        }
      ]
    },
    {
      name = "weekly"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
      retention_rule = [
        {
          name     = "weekly"
          priority = 1
          life_cycle = {
            duration        = "P30D"
            data_store_type = "VaultStore"
          }
          criteria = {
            absolute_criteria = "FirstOfDay"
          }
        }
      ]
    }
  ]

  postgresql_instances = [
    {
      name                = "pg1-backup"
      location            = "eastus"
      server_name         = "my-postgres-server-1"
      resource_group_name = "my-db-rg"
      policy_key          = "daily"
    },
    {
      name                = "pg2-backup"
      location            = "eastus"
      server_name         = "my-postgres-server-2"
      resource_group_name = "my-db-rg-2"
      policy_key          = "weekly"
    }
  ]

  # MYSQL configuration (disabled by Azure for now)
  mysql_policies = [
    {
      name = "daily"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "VaultStore"
        }
      }
    },
    {
      name = "weekly"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P7D"
          data_store_type = "VaultStore"
        }
      }
    }
  ]

  mysql_instances = [
    {
      name                = "mysql1-backup"
      location            = "eastus"
      server_name         = "my-mysql-server-1"
      resource_group_name = "my-db-rg"
      policy_key          = "daily"
    }
  ]

  # DISKS configuration
  disk_policies = [
    {
      name = "daily-disk-policy"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT10M"]
      default_retention_duration      = "P7D"
    }
  ]

  disk_instances = [
    {
      name                = "disk1-backup"
      location            = "eastus"
      disk_resource_group = "my-disk-rg"
      policy_key          = "daily-disk-policy"
    }
  ]

  # BLOB configuration
  blob_policies = [
    {
      name                                 = "daily"
      backup_repeating_time_intervals      = ["R/2025-10-23T08:00:00Z/PT10M"]
      operational_default_retention_duration = "P7D"
      vault_default_retention_duration     = "P30D"
    },
    {
      name                                 = "weekly"
      backup_repeating_time_intervals      = ["R/2025-10-23T08:00:00Z/PT10M"]
      operational_default_retention_duration = "P30D"
      vault_default_retention_duration     = "P90D"
    }
  ]

  blob_instances = [
    {
      name                          = "blob1-backup"
      location                      = "eastus"
      storage_account_name          = "my-storage-account-1"
      storage_account_resource_group = "my-storage-rg"
      storage_account_container_names = ["container1"]
      policy_key                    = "daily"
    },
    {
      name                          = "blob2-backup"
      location                      = "eastus"
      storage_account_name          = "my-storage-account-2"
      storage_account_resource_group = "my-storage-rg-2"
      storage_account_container_names = ["container2"]
      policy_key                    = "weekly"
    }
  ]

  # KUBERNETES configuration
  kubernetes_policies = [
    {
      name = "daily-k8s-policy"
      backup_repeating_time_intervals = ["R/2025-10-23T08:00:00Z/PT24H"]
      default_retention_rule = {
        life_cycle = {
          duration        = "P30D"
          data_store_type = "OperationalStore"
        }
      }
    }
  ]

  kubernetes_instances = [
    {
      name                        = "k8s1-backup"
      location                    = "eastus"
      cluster_name                = "my-k8s-cluster-1"
      resource_group_name         = "my-k8s-rg"
      snapshot_resource_group_name = "my-k8s-snapshots-rg"
      policy_key                  = "daily-k8s-policy"
      extension_configuration = {
        bucket_name                 = "my-bucket"
        bucket_resource_group_name  = "my-storage-rg"
        bucket_storage_account_name = "my-storage-account-1"
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) | resource |
| [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk) | resource |
| [azurerm_data_protection_backup_instance_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster) | resource |
| [azurerm_data_protection_backup_instance_mysql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_mysql_flexible_server) | resource |
| [azurerm_data_protection_backup_instance_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server) | resource |
| [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) | resource |
| [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk) | resource |
| [azurerm_data_protection_backup_policy_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_kubernetes_cluster) | resource |
| [azurerm_data_protection_backup_policy_mysql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_mysql_flexible_server) | resource |
| [azurerm_data_protection_backup_policy_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql_flexible_server) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_kubernetes_cluster_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension) | resource |
| [azurerm_kubernetes_cluster_trusted_access_role_binding.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_trusted_access_role_binding) | resource |
| [azurerm_resource_provider_registration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration) | resource |
| [azurerm_role_assignment.aks_contributor_on_snapshot_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.disk_backup_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.extension_storage_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kubernetes_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.mysql_backup_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.mysql_rg_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.postgresql_ltr_backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.postgresql_rg_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.snapshot_rg_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vault_backup_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vault_reader_on_kubernetes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vault_reader_on_snapshot_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_disk) | data source |
| [azurerm_mysql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mysql_flexible_server) | data source |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/postgresql_flexible_server) | data source |
| [azurerm_resource_group.disk_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.kubernetes_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.mysql_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.postgresql_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.snapshot_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_resource_group_name"></a> [backup\_resource\_group\_name](#input\_backup\_resource\_group\_name) | Name of the resource group for backups | `string` | `null` | no |
| <a name="input_blob_instances"></a> [blob\_instances](#input\_blob\_instances) | List of backup instances for blobs | <pre>list(object({<br/>    name                            = string<br/>    location                        = string<br/>    storage_account_name            = string<br/>    storage_account_resource_group  = string<br/>    storage_account_container_names = optional(list(string))<br/>    policy_key                      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_blob_policies"></a> [blob\_policies](#input\_blob\_policies) | List of backup policies for blobs | <pre>list(object({<br/>    name                                   = string<br/>    backup_repeating_time_intervals        = optional(list(string))<br/>    operational_default_retention_duration = optional(string)<br/>    time_zone                              = optional(string)<br/>    vault_default_retention_duration       = optional(string)<br/>    retention_rule = optional(list(object({<br/>      name     = string<br/>      priority = number<br/>      criteria = object({<br/>        absolute_criteria      = optional(string)<br/>        days_of_week           = optional(list(string))<br/>        days_of_month          = optional(list(number))<br/>        months_of_year         = optional(list(string))<br/>        weeks_of_month         = optional(list(string))<br/>        scheduled_backup_times = optional(list(string))<br/>      })<br/>      life_cycle = object({<br/>        data_store_type = string<br/>        duration        = string<br/>      })<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_disk_instances"></a> [disk\_instances](#input\_disk\_instances) | List of backup instances for disks | <pre>list(object({<br/>    name                = string<br/>    location            = string<br/>    disk_resource_group = string<br/>    policy_key          = string<br/>  }))</pre> | `[]` | no |
| <a name="input_disk_policies"></a> [disk\_policies](#input\_disk\_policies) | List of backup policies for disks | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    default_retention_duration      = string<br/>    time_zone                       = optional(string)<br/>    retention_rule = optional(list(object({<br/>      name     = string<br/>      duration = string<br/>      priority = number<br/>      criteria = object({<br/>        absolute_criteria = optional(string)<br/>      })<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_kubernetes_instances"></a> [kubernetes\_instances](#input\_kubernetes\_instances) | List of Kubernetes cluster backup instances | <pre>list(object({<br/>    name                         = string<br/>    location                     = string<br/>    cluster_name                 = string<br/>    resource_group_name          = string<br/>    snapshot_resource_group_name = string<br/>    policy_key                   = string<br/>    backup_datasource_parameters = optional(object({<br/>      excluded_namespaces              = optional(list(string))<br/>      excluded_resource_types          = optional(list(string))<br/>      cluster_scoped_resources_enabled = optional(bool)<br/>      included_namespaces              = optional(list(string))<br/>      included_resource_types          = optional(list(string))<br/>      label_selectors                  = optional(list(string))<br/>      volume_snapshot_enabled          = optional(bool)<br/>    }))<br/>    extension_configuration = optional(object({<br/>      bucket_name                 = optional(string)<br/>      bucket_resource_group_name  = optional(string)<br/>      bucket_storage_account_name = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_kubernetes_policies"></a> [kubernetes\_policies](#input\_kubernetes\_policies) | List of backup policies for Kubernetes clusters | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    time_zone                       = optional(string)<br/>    default_retention_rule = object({<br/>      life_cycle = object({<br/>        duration        = string<br/>        data_store_type = optional(string, "OperationalStore")<br/>      })<br/>    })<br/>    retention_rule = optional(list(object({<br/>      name     = string<br/>      priority = number<br/>      life_cycle = object({<br/>        data_store_type = optional(string, "OperationalStore")<br/>        duration        = string<br/>      })<br/>      criteria = object({<br/>        absolute_criteria      = optional(string)<br/>        days_of_week           = optional(list(string))<br/>        months_of_year         = optional(list(string))<br/>        weeks_of_month         = optional(list(string))<br/>        scheduled_backup_times = optional(list(string))<br/>      })<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_mysql_instances"></a> [mysql\_instances](#input\_mysql\_instances) | List of MySQL Flexible Server backup instances | <pre>list(object({<br/>    name                = string<br/>    location            = string<br/>    server_name         = string<br/>    resource_group_name = string<br/>    policy_key          = string<br/>  }))</pre> | `[]` | no |
| <a name="input_mysql_policies"></a> [mysql\_policies](#input\_mysql\_policies) | List of backup policies for MySQL Flexible Server | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    time_zone                       = optional(string)<br/>    default_retention_rule = object({<br/>      life_cycle = object({<br/>        duration        = string<br/>        data_store_type = optional(string, "VaultStore")<br/>      })<br/>    })<br/>    retention_rule = optional(list(object({<br/>      name     = string<br/>      priority = number<br/>      life_cycle = object({<br/>        data_store_type = optional(string, "VaultStore")<br/>        duration        = string<br/>      })<br/>      criteria = object({<br/>        absolute_criteria      = optional(string)<br/>        days_of_week           = optional(list(string))<br/>        months_of_year         = optional(list(string))<br/>        weeks_of_month         = optional(list(string))<br/>        scheduled_backup_times = optional(list(string))<br/>      })<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_postgresql_instances"></a> [postgresql\_instances](#input\_postgresql\_instances) | List of backup instances for PostgreSQL Flexible Server | <pre>list(object({<br/>    name                = string<br/>    location            = string<br/>    server_name         = string<br/>    policy_key          = string<br/>    resource_group_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_postgresql_policies"></a> [postgresql\_policies](#input\_postgresql\_policies) | List of backup policies for PostgreSQL Flexible Server | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    time_zone                       = optional(string)<br/>    default_retention_rule = object({<br/>      life_cycle = object({<br/>        data_store_type = optional(string, "VaultStore")<br/>        duration        = string<br/>      })<br/>    })<br/>    retention_rule = optional(list(object({<br/>      name     = string<br/>      priority = number<br/>      life_cycle = object({<br/>        data_store_type = optional(string, "VaultStore")<br/>        duration        = string<br/>      })<br/>      criteria = object({<br/>        absolute_criteria      = optional(string)<br/>        days_of_week           = optional(list(string))<br/>        months_of_year         = optional(list(string))<br/>        weeks_of_month         = optional(list(string))<br/>        scheduled_backup_times = optional(list(string))<br/>      })<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vault"></a> [vault](#input\_vault) | Backup vault configuration | <pre>object({<br/>    name                         = string<br/>    location                     = string<br/>    datastore_type               = string<br/>    redundancy                   = string<br/>    cross_region_restore_enabled = optional(bool)<br/>    retention_duration_in_days   = optional(number)<br/>    immutability                 = optional(string)<br/>    soft_delete                  = optional(string)<br/>    identity = optional(object({<br/>      type = string<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples):

- [blobs](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/blobs) - Example provisioning backup for blobs with custom policy.
- [disks](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/disks) - Example provisioning backup for disks with custom policy.
- [postgresql](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/postgresql) - Example provisioning backup for postgresql with custom policies.

## Remote resources

- **Azure Data Protection Backup Vault**: [azurerm\_data\_protection\_backup\_vault documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- **Azure Disk Backup**: [azurerm\_data\_protection\_backup\_instance\_disk documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk)
- **Azure Blob Backup**: [azurerm\_data\_protection\_backup\_instance\_blob\_storage documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage)
- **Azure Kubernetes Backup**: [azurerm\_data\_protection\_backup\_instance\_kubernetes\_cluster documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster)
- **Azure PostgreSQL Backup**: [azurerm\_data\_protection\_backup\_instance\_postgresql\_flexible\_server documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->