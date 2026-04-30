## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-oidc/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-oidc/_examples/basic) — Root module loading `applications` from `apps.yaml`; configure **azurerm** and **azuread** before apply (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-oidc/_examples/comprehensive) — Illustrative `values.reference.yaml` for multiple apps, roles, scopes, and federated credentials (see folder README).

## Resources

**azuread** registry docs use **2.15.0**, aligned with `versions.tf` (`~> 2.15.0`). **azurerm** links use **4.16.0** as a representative baseline compatible with the module constraint (`> 3.0.0`).

- **Workload identity federation (Microsoft Entra)**: [https://learn.microsoft.com/entra/workload-id/workload-identity-federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)
- **azuread_application**: [https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/application](https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/application)
- **azuread_service_principal**: [https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/service_principal](https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/service_principal)
- **azuread_application_federated_identity_credential**: [https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/application_federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azuread/2.15.0/docs/resources/application_federated_identity_credential)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/2.15.0](https://registry.terraform.io/providers/hashicorp/azuread/2.15.0)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
