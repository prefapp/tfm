## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-disks/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-disks/_examples/basic) — Resource group plus one managed disk via the module; configure `azurerm` and adjust names before apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-disks/_examples/comprehensive) — Illustrative `values.reference.yaml` for multiple disks, tags, and optional `assign_role` (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.5.0**, matching the pinned `azurerm` range in `versions.tf` (`~> 4.5.0`).

- **Azure managed disks**: [https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview)
- **azurerm_managed_disk**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/managed_disk)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment)
- **azurerm_resource_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
