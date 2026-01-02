## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_role_assignment.role_assignment_over_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_role"></a> [assign\_role](#input\_assign\_role) | Whether to assign a role definition to the managed disk. | `bool` | `false` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | A map of managed disk configurations. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the managed disk should be created. | `string` | n/a | yes |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | The ID of the principal to assign the role definition to. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the managed disk should be created. | `string` | n/a | yes |
| <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name) | The name of the role definition to assign to the managed disk. | `string` | `"Contributor"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disk_ids"></a> [disk\_ids](#output\_disk\_ids) | n/a |
| <a name="output_disk_names"></a> [disk\_names](#output\_disk\_names) | Output section |

## Notes

- Empty disks or disks based on another disk can be created.
- It is not necessary to assign a role to a disk.
- **There is a lifecycle rule to ignore changes to disk size, as the CSI Driver may resize the disk outside of Terraform.**

## Example

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
        storage_account_type: Premium_LRS
  principal_id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```
