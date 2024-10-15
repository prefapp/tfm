# Azure disks with role

## Overview

This module creates azure disks and assign a role to manage them, to a service principal.

## DOC

- [Resource terraform - managed disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)
- [Resource terraform - role assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks?ref=<version>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-disks?ref=1.0.0"
}
```

## Notes

- Empty disks or disks based on another disk can be created.
- It is not necessary to assign a role to a disk.

### Set a data .tfvars

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The Azure region where the managed disk should be created. | string | n/a | yes |
| resource_group_name | The name of the resource group in which the managed disk should be created. | string | n/a | yes |
| disks | A map of managed disk configurations. | map(object({<br> name: string (required)<br> disk_size_gb: number (required)<br> sku: string (required)<br> })) | n/a | yes |
| role_definition_name | The name of the role definition to assign to the managed disk. | string | `Contributor` | no |
| principal_id | The ID of the principal to assign the role definition to. | string | n/a | no |
| assign_role | Whether to assign the role definition to the principal. | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| disk_names | The names of the managed disks. |
| disk_ids | The IDs of the managed disks. |

## Example

```yaml
resource_group_name: "REDACTED-RESOURCE-GROUP"
location: "REDACTED-LOCATION"
disks:
    - name: disk-1
      storage_account_type: StandardSSD_LRS
    - name: disk-2
    - name: disk-3
    - name: disk-4
      storage_account_type: Premium_LRS
principal_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```
