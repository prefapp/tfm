# `azure-disks`

## Overview

Terraform module that creates one or more **Azure managed disks** (`azurerm_managed_disk`) in an existing resource group, with optional **Azure RBAC role assignments** scoped to each disk. Tags can be merged from the resource group or set only from module input.

**Prerequisites**

- Existing **resource group** (`resource_group_name`).
- **`location`** consistent with that resource group (the module does not read location from the data source).

**Behaviour notes (as implemented)**

- **`disks`** must be a **list** of objects; each object must include **`name`** (used as the Terraform `for_each` key and as the Azure disk name). Optional keys supported by `lookup` in [`main.tf`](main.tf): `storage_account_type` (default `StandardSSD_LRS`), `create_option` (default `Empty`), `source_resource_id` (default `null`), `disk_size_gb` (default `4`).
- **`lifecycle.ignore_changes`** includes **`disk_size_gb`** so in-cluster resizes (for example via CSI) do not fight Terraform.
- **`assign_role`**: when `true`, creates `azurerm_role_assignment` per disk. The resource uses `lookup(each.value, "role_definition_name", "Contributor")` where `each.value` is the **managed disk resource**, not your `disks` list entry—so the lookup does not read per-disk settings from `var.disks`; the effective role name is **`Contributor`** in normal use. The root module variable **`role_definition_name`** is **not referenced** in the current implementation.
- **`principal_id`**: required when `assign_role` is `true` (use a valid object ID; the default empty string will fail assignment).

## Basic usage

```hcl
module "disks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks?ref=azure-disks-v1.1.2"

  resource_group_name = "example-rg"
  location              = "westeurope"

  disks = [
    { name = "data-01", disk_size_gb = 64, storage_account_type = "Premium_LRS" },
    { name = "data-02" }
  ]

  assign_role  = false
  principal_id = ""

  tags_from_rg = true
  tags         = { workload = "example" }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Resource group data source, managed disks, role assignments |
| `locals.tf` | Tag merge |
| `variables.tf` | Inputs |
| `outputs.tf` | Disk names and IDs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
