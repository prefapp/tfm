
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples):

- [with_nic](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/with_nic) - Example configuring backup for disks with custom network interface configuration.
- [with_custom_data](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/with_custom_data) - Example provisioning backup for blob storage with custom policy.
- [with_vault_admin_pass](https://github.com/prefapp/tfm/tree/main/modules/azure-backup-vault/_examples/with_vault_admin_pass) - Example using Key Vault for secure backup configuration.
- See documentation for more advanced scenarios (Kubernetes, PostgreSQL, MySQL, etc).

## Remote resources

- **Azure Data Protection Backup Vault**: [azurerm_data_protection_backup_vault documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- **Azure Disk Backup**: [azurerm_data_protection_backup_instance_disk documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk)
- **Azure Blob Backup**: [azurerm_data_protection_backup_instance_blob_storage documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage)
- **Azure Kubernetes Backup**: [azurerm_data_protection_backup_instance_kubernetes_cluster documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster)
- **Azure PostgreSQL Backup**: [azurerm_data_protection_backup_instance_postgresql_flexible_server documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
