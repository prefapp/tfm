## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/basic) — Resource group plus Key Vault with one access policy by `object_id`; configure `azurerm` / `azuread` and replace placeholders before plan/apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-kv/_examples/comprehensive) — Illustrative `values.reference.yaml` for tags, access policies (object ID and Entra lookups), and RBAC notes (see folder README).

## Resources

Terraform **azurerm** docs use **4.21.0** as a baseline aligned with `versions.tf` (`>= 4.21.0`). **azuread** docs use **2.53.0** (`~> 2.53.0`).

- **Azure Key Vault**: [https://learn.microsoft.com/azure/key-vault/general/overview](https://learn.microsoft.com/azure/key-vault/general/overview)
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
