## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/basic) — File share backup only (Recovery Services vault); replace resource group, storage account ID, and names.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-sa-backup/_examples/comprehensive) — **`values.reference.yaml`**: combined illustration for `backup_share`, `backup_blob`, and tags (maintain large YAML here, not inside the generated README).

## Remote resources

- **Azure Backup / Storage**: [https://learn.microsoft.com/azure/backup/](https://learn.microsoft.com/azure/backup/)
- **Terraform `azurerm_recovery_services_vault`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault)
- **Terraform `azurerm_data_protection_backup_vault`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
