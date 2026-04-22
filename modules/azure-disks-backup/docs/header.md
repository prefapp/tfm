# `azure-disks-backup`

## Overview

Terraform module that provisions an **Azure Backup vault for managed disks** using the Data Protection platform: `azurerm_data_protection_backup_vault`, disk backup policies, backup instances per disk, and **RBAC** for the vault’s **system-assigned managed identity** (`Disk Snapshot Contributor` on the vault resource group, `Disk Backup Reader` on each source disk).

**Prerequisites**

- Existing **resource group** (`resource_group_name`) where the vault is created and where **disk snapshots are stored** (`snapshot_resource_group_name` in code is always this same resource group).
- **Managed disks** referenced in `backup_instances` must already exist in the given `disk_resource_group` values; the module reads them with `azurerm_managed_disk` data sources.
- **`location`** for the vault and backup instances is taken from the vault resource group data source (you do not pass `location` as a variable).

**Behaviour notes (as implemented)**

- **`backup_policies`**: `for_each` is keyed by `policy.name`; each `backup_policy_name` in `backup_instances` must match one of those names.
- **`backup_instances`**: `for_each` is keyed by **`disk_name`**. Each `disk_name` must be **unique** in the list; duplicate names would collide in state.
- **Snapshots**: `azurerm_data_protection_backup_instance_disk` sets `snapshot_resource_group_name` to **`var.resource_group_name`** (the vault resource group). There is **no** per-instance field for snapshot RG in `variables.tf`—older README examples that showed `snapshot_resource_group_name` on each instance do not match the current code.
- **Tags**: Same pattern as other Azure modules—`tags_from_rg` merges resource group tags with `tags`.
- A **commented** `null_resource` validation in `data.tf` once aimed to forbid disks in the same RG as the vault; it is **not active**. Confirm Microsoft / operational constraints for your subscription if you colocate resources.

## Basic usage

```hcl
module "disks_backup" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks-backup?ref=azure-disks-backup-v1.2.3"

  resource_group_name = "example-backup-rg"
  vault_name            = "example-disk-backup-vault"

  datastore_type             = "VaultStore"
  redundancy                 = "LocallyRedundant"
  soft_delete                = "Off"
  retention_duration_in_days = 14

  backup_policies = [
    {
      name                            = "daily"
      backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT24H"]
      default_retention_duration      = "P7D"
      time_zone                       = "Coordinated Universal Time"
      retention_rules = [
        {
          name     = "Daily"
          duration = "P7D"
          priority = 25
          criteria = { absolute_criteria = "FirstOfDay" }
        }
      ]
    }
  ]

  backup_instances = [
    {
      disk_name           = "data-01"
      disk_resource_group = "example-data-rg"
      backup_policy_name  = "daily"
    }
  ]

  tags_from_rg = false
  tags         = { workload = "example" }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `backup_vault.tf` | Backup vault + managed identity |
| `backup_policy.tf` | Disk backup policies |
| `protection_instance.tf` | Backup instances (disks) |
| `role_assignments.tf` | RBAC for vault identity |
| `data.tf` | Resource group + managed disk data sources |
| `locals.tf` | Tag merge |
| `variables.tf` | Inputs |
| `outputs.tf` | Outputs |
| `versions.tf` | Terraform and provider versions |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
