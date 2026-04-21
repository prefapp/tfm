## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/basic) — User-assigned managed identity with one subscription-scope RBAC assignment (replace RG, scope, and names — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) — Illustrative YAML for RBAC, federated credentials, and optional Key Vault access policies (`values.reference.yaml`; see folder README).

## Resources

Terraform resource docs use **4.16.0**, matching the pinned `azurerm` range in `versions.tf` (`~> 4.16.0`).

- **Managed identities for Azure resources**: [https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- **azurerm_user_assigned_identity**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/user_assigned_identity)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment)
- **azurerm_federated_identity_credential**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/federated_identity_credential)
- **azurerm_key_vault_access_policy**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/key_vault_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/key_vault_access_policy)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
