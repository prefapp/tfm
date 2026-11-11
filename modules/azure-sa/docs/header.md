# Azure Storage Account Terraform module (`azure-sa`)

## Overview

This module creates an **Azure Storage Account** in an existing resource group, applies **network rules** (subnets from data sources plus optional extra subnet IDs and private link access), and can provision **blob containers**, **file shares**, **queues**, **tables**, optional **lifecycle management policies**, and **Microsoft Defender for Storage** (advanced threat protection) when enabled.

The module does **not** create the resource group or virtual networks; it looks up the resource group for location/tags and resolves allowed subnets via **`azurerm_subnet`** data sources.

## Key features

- **Storage account**: Tier, replication, kind, TLS, public access, optional managed identity and blob service properties (versioning, retention, restore policy) with validations on common combinations.
- **Network**: `azurerm_storage_account_network_rules` combining subnets from `allowed_subnets`, `additional_allowed_subnet_ids`, optional IP rules, bypass, and private link access entries.
- **Data plane resources**: Optional containers, shares, queues, and tables via `for_each` maps.
- **Outputs**: Storage account `id`, `name`, `primary_blob_endpoint`, and maps of child resource IDs (`container_ids`, `share_ids`, `queue_ids`, `table_ids`).
- **Lifecycle**: Optional `azurerm_storage_management_policy` when `lifecycle_policy_rules` is set.
- **Object replication**: Optional replication of block blobs to a separately managed account in this or another region.
- **WORM / immutable blob storage**: Optional account-level `immutability_policy` and per-container time-based retention policies (`azurerm_storage_container_immutability_policy`).
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

## Object replication

Configure `object_replication` on the source account with the destination account ID and one or more container pairs. The destination account and its containers must already exist and be managed separately. Both accounts need blob versioning; the source also needs change feed. Object replication supports block blobs only and doesn't support hierarchical namespace-enabled accounts.

```hcl
object_replication = {
  destination_storage_account_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<destination-account>"
  rules = [
    {
      source_container_name        = "data"
      destination_container_name   = "data"
      copy_blobs_created_after     = "Everything"
      filter_out_blobs_with_prefix = ["temporary/"]
    }
  ]
}
```

`copy_blobs_created_after` defaults to `OnlyNewObjects`. Set it to `Everything` to include existing blobs, or provide an RFC3339 timestamp for a custom copy boundary. Replication is asynchronous. While a policy is active, writes to the destination container are blocked. Removing the Terraform resource removes the policy from both accounts but does not delete the accounts or containers. Import uses the composite source/destination policy ID documented for `azurerm_storage_object_replication`.

Azure may fail to replicate updates or deletes when the destination container has an immutability policy. Validate this combination against the workload before enabling WORM on the destination. Archived blobs cannot be replicated.

## WORM (immutable blob storage)

WORM is **not** configured through `lifecycle_policy_rules` (that input maps to *Lifecycle management*, which only tiers and deletes blobs). WORM is implemented with **immutability policies** (time-based retention), which this module exposes at two scopes:

- **Container scope** (recommended, `containers[*].immutability_policy`): creates `azurerm_storage_container_immutability_policy`. It can be added to an **existing** account and container without recreating anything, and it only affects that container.
- **Account scope** (`storage_account.immutability_policy`): default policy inherited by objects without their own policy. Azure only accepts this at account creation, so adding or removing it on an existing account **forces the storage account to be recreated** (data loss). Use the container scope on accounts that already exist.

Precedence is object > container > account.

```hcl
storage_account = {
  name                     = "mystorageacctuniq02"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

containers = [
  {
    name                  = "evidence"
    container_access_type = "private"
    immutability_policy = {
      immutability_period_in_days     = 365
      locked                          = false
      protected_append_writes_enabled = true
    }
  }
]
```

Notes:

- `locked = false` (Unlocked) allows testing and deleting the policy. `locked = true` is **irreversible**: the retention period can only be increased (5 times max) and neither the container nor the storage account can be deleted until every blob is out of retention. A `terraform destroy` will fail.
- `protected_append_writes_enabled` (append blobs) and `protected_append_writes_all_enabled` (block and append blobs) are mutually exclusive.
- Immutability is independent of `account_replication_type`: changing `LRS` to `GRS` is an in-place update (no recreation), whereas switching between ZRS and non-ZRS families does force a new account.

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
