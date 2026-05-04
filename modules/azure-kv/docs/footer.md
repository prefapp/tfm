## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — Key Vault with **RBAC** enabled and no access policies; set an existing resource group and a globally unique vault name (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — Reference HCL and YAML for **access policies** (object ID and Azure AD lookups) and tag options (`values.reference.yaml`; see folder README).

## Resources

Terraform **azurerm** links below use **4.21.0** as a baseline aligned with the minimum `azurerm` version in `versions.tf` (`>= 4.21.0`). **azuread** links use **2.53.0**, aligned with `versions.tf` (`~> 2.53.0`). Pinned versions in your workspace appear in the **Providers** table after regenerating this README with `terraform-docs .`, as described in [README.md generation](https://github.com/prefapp/tfm/blob/main/CONTRIBUTING.md#5-readmemd-generation).

- **Azure Key Vault**: [https://learn.microsoft.com/azure/key-vault/](https://learn.microsoft.com/azure/key-vault/)
- **azurerm_key_vault**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/resources/key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/resources/key_vault)
- **azurerm_client_config** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/client_config](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/client_config)
- **azurerm_resource_group** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0/docs/data-sources/resource_group)
- **azuread_user** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/user)
- **azuread_group** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/group)
- **azuread_service_principal** (data source): [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0/docs/data-sources/service_principal)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.21.0)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/2.53.0](https://registry.terraform.io/providers/hashicorp/azuread/2.53.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
