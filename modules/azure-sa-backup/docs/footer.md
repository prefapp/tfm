## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/basic) — Azure Files backup via Recovery Services vault (`backup_share`); set RG, storage account ID, vault/policy/share names (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/comprehensive) — Reference YAML illustrating `backup_share`, `backup_blob`, and tags (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.6.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.6.0`).

- **Azure Backup**: [https://learn.microsoft.com/azure/backup/](https://learn.microsoft.com/azure/backup/)
- **azurerm_recovery_services_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0/docs/resources/recovery_services_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0/docs/resources/recovery_services_vault)
- **azurerm_data_protection_backup_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0/docs/resources/data_protection_backup_vault)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.6.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
