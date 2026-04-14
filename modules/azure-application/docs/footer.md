## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-application/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-application/_examples/basic) — Minimal module call with empty `members` and `msgraph_roles` (adjust redirects and authentication for your tenant).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-application/_examples/comprehensive) — Optional client secret, federated credential, and Azure RBAC assignment patterns; see `values.reference.yaml` for copy-paste shapes.

## Providers and `time`

This module uses the **`time_rotating`** resource for optional client secret rotation. The module’s `versions.tf` does not pin **`hashicorp/time`**; ensure your root module (or lockfile) includes a compatible `time` provider if you enable `client_secret`.

## Remote resources

- **App registrations**: [https://learn.microsoft.com/entra/identity-platform/quickstart-register-app](https://learn.microsoft.com/entra/identity-platform/quickstart-register-app)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/latest](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
