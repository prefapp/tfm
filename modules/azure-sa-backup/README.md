<!-- BEGIN_TF_DOCS -->
# Azure Storage Account backup Terraform module (`azure-sa-backup`)

## Overview

This module configures **Azure Backup** for an existing **storage account**, in two optional paths:

- **Azure Files**: Recovery Services vault, registration of the storage account as a backup container, a **file share backup policy**, and one **protected file share** per entry in `source_file_share_name`.
- **Blobs (Data Protection)**: Backup vault, **blob backup policy**, **role assignment** on the storage account for the vault identity, and a **blob backup instance** (optional container scope).

You can enable **only shares**, **only blobs**, or **both**. The module reads an existing **resource group** (`backup_resource_group_name`) for location and optional tag merge; it does **not** create that resource group or the storage account.

## Key features

- **Tags**: `tags` plus optional merge from the backup resource group when `tags_from_rg = true` (default `false`).
- **Conditional resources**: `backup_share` and `backup_blob` are each optional (`null` disables that path).

## Prerequisites

- Existing **resource group** for backup resources (`backup_resource_group_name`).
- Existing **storage account** and, for file share backup, existing **file share** names listed in `backup_share.source_file_share_name`.
- Appropriate **permissions** for Terraform in the subscription (Backup Contributor / relevant roles as required by your org).

## Basic usage

Provide `backup_resource_group_name`, `storage_account_id`, and at least one of `backup_share` or `backup_blob`. See the **Inputs** table for the full object shapes.

### Example (file share backup only)

```hcl
module "storage_backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-sa-backup?ref=<version>"

  backup_resource_group_name = "my-backup-rg"
  storage_account_id         = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sa-rg/providers/Microsoft.Storage/storageAccounts/mystorage"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  backup_share = {
    policy_name                  = "daily-backup-policy"
    recovery_services_vault_name = "my-rsvault"
    sku                          = "Standard"
    source_file_share_name       = ["myshare"]
    timezone                     = "UTC"
    backup = {
      frequency = "Daily"
      time      = "02:00"
    }
    retention_daily = {
      count = 7
    }
  }

  backup_blob             = null
  lifecycle_policy_rule   = null
}
```

## File structure

```
.
├── CHANGELOG.md
├── blobs.tf
├── locals.tf
├── main.tf
├── shares.tf
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.6.0 |

## Modules

No modules.

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
| <a name="input_backup_resource_group_name"></a> [backup\_resource\_group\_name](#input\_backup\_resource\_group\_name) | Name of the existing resource group where backup vaults and policies are created (also used for the data source and optional tag merge). | `string` | n/a | yes |
| <a name="input_backup_share"></a> [backup\_share](#input\_backup\_share) | Specifies the backup configuration for the storage share | <pre>object({<br/>    policy_name                  = string<br/>    recovery_services_vault_name = string<br/>    sku                          = string<br/>    soft_delete_enabled          = optional(bool)<br/>    storage_mode_type            = optional(string, "GeoRedundant")<br/>    cross_region_restore_enabled = optional(bool)<br/>    source_file_share_name       = list(string)<br/>    identity = optional(object({<br/>      type         = optional(string, "SystemAssigned")<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>    encryption = optional(object({<br/>      key_id                            = optional(string, null)<br/>      infrastructure_encryption_enabled = optional(bool, false)<br/>      user_assigned_identity_id         = optional(string, null)<br/>      use_system_assigned_identity      = optional(bool, false)<br/>    }))<br/>    timezone = optional(string)<br/>    backup = object({<br/>      frequency = string<br/>      time      = string<br/>    })<br/>    retention_daily = object({<br/>      count = number<br/>    })<br/>    retention_weekly = optional(object({<br/>      count    = number<br/>      weekdays = optional(list(string), ["Sunday"])<br/>    }))<br/>    retention_monthly = optional(object({<br/>      count    = number<br/>      weekdays = optional(list(string), ["Sunday"])<br/>      weeks    = optional(list(string), ["First"])<br/>      days     = optional(list(number))<br/>    }))<br/>    retention_yearly = optional(object({<br/>      count    = number<br/>      months   = optional(list(string), ["January"])<br/>      weekdays = optional(list(string), ["Sunday"])<br/>      weeks    = optional(list(string), ["First"])<br/>      days     = optional(list(number))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_lifecycle_policy_rule"></a> [lifecycle\_policy\_rule](#input\_lifecycle\_policy\_rule) | Declared for future use; no resources in this module consume this variable yet. | <pre>list(object({<br/>    name    = string<br/>    enabled = bool<br/>    filters = object({<br/>      prefix_match = list(string)<br/>      blob_types   = list(string)<br/>    })<br/>    actions = object({<br/>      base_blob = object({ delete_after_days_since_creation_greater_than = number })<br/>      snapshot  = object({ delete_after_days_since_creation_greater_than = number })<br/>      version   = object({ delete_after_days_since_creation = number })<br/>    })<br/>  }))</pre> | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Full Azure resource ID of the storage account to protect (file shares and/or blob backup). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

No outputs.

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/basic) — File share backup only (Recovery Services vault); replace resource group, storage account ID, and names.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/comprehensive) — **`values.reference.yaml`**: combined illustration for `backup_share`, `backup_blob`, and tags (maintain large YAML here, not inside the generated README).

## Remote resources

- **Azure Backup / Storage**: [https://learn.microsoft.com/azure/backup/](https://learn.microsoft.com/azure/backup/)
- **Terraform `azurerm_recovery_services_vault`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault)
- **Terraform `azurerm_data_protection_backup_vault`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->