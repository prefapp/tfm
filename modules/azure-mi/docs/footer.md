## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/basic) — Minimal user-assigned identity with empty `rbac`, `federated_credentials`, and `access_policies` (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) — Reference HCL and YAML for RBAC, federated GitHub/Kubernetes/OIDC credentials, and optional Key Vault access policies (`values.reference.yaml`; see folder README).

## Remote resources

Terraform **azurerm** links below use **4.16.0**, aligned with `versions.tf` (`~> 4.16.0`). Provider version constraints for your workspace appear in the **Providers** table above after regenerating this README with `terraform-docs .`, as described in [README.md generation](https://github.com/prefapp/tfm/blob/main/CONTRIBUTING.md#5-readmemd-generation).

- **Managed identities**: [https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/)
- **azurerm_user_assigned_identity**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/user_assigned_identity)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment)
- **azurerm_federated_identity_credential**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/federated_identity_credential)
- **azurerm_key_vault_access_policy**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/key_vault_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/key_vault_access_policy)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
