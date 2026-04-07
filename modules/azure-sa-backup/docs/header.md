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
