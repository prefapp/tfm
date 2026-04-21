## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples/basic) — Backup vault, policies, and disk backup instances; ensure managed disks exist or adjust inputs before apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-disks-backup/_examples/comprehensive) — Illustrative `values.reference.yaml` for multiple policies and instances (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.5.0**, matching the pinned `azurerm` version in `versions.tf`.

- **Azure Backup for managed disks**: [https://learn.microsoft.com/azure/backup/disk-backup-overview](https://learn.microsoft.com/azure/backup/disk-backup-overview)
- **azurerm_data_protection_backup_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault)
- **azurerm_data_protection_backup_policy_disk**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk)
- **azurerm_data_protection_backup_instance_disk**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment)
- **azurerm_resource_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group)
- **azurerm_managed_disk** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
