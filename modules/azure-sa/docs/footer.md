## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/basic) — Minimal storage account with permissive network defaults; set an existing RG and a globally unique storage account name (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-sa/_examples/comprehensive) — Reference YAML for containers, queues, tables, shares, lifecycle rules, and stricter networking (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.38.1** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.38.1`).

- **Azure Storage**: [https://learn.microsoft.com/azure/storage/](https://learn.microsoft.com/azure/storage/)
- **azurerm_storage_account**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1/docs/resources/storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1/docs/resources/storage_account)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1](https://registry.terraform.io/providers/hashicorp/azurerm/4.38.1)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
