# Azure Managed Disks Terraform Module

## Overview

This Terraform module allows you to create and manage managed disks in Azure, with support for:
- Creation of multiple disks with different configurations.
- Optional role assignment on disks.
- Flexible tagging and tag inheritance from the Resource Group.

## Main features
- Create managed disks of different types and sizes.
- Optional role assignment to disks (e.g., Contributor).
- Support for tags and inheritance from the Resource Group.
- Ignores disk size changes in lifecycle (useful for CSI Driver).

## Complete usage example

```yaml
values:
  tags_from_rg: true
  resource_group_name: "REDACTED-RESOURCE-GROUP"
  location: "REDACTED-LOCATION"
  disks:
      - name: disk-1
        storage_account_type: StandardSSD_LRS
      - name: disk-2
      - name: disk-3
      - name: disk-4
```

## Notes
- You can create empty disks or base them on another disk.
- Assigning a role to a disk is not mandatory.
- Disk size is ignored in changes to avoid conflicts with the CSI Driver.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```