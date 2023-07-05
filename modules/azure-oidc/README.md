## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.15.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.gh_oidc_ad_app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.gh_oidc_identity_credential](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.gh_oidc_service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.gh_oidc_service_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization"></a> [organization](#input\_organization) | n/a | `string` | n/a | yes |
| <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name) | n/a | `string` | `"Contributor"` | no |
| <a name="input_subs"></a> [subs](#input\_subs) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_azure_client_id"></a> [oidc\_azure\_client\_id](#output\_oidc\_azure\_client\_id) | AZURE\_CLIENT\_ID |
| <a name="output_oidc_azure_subscription_id"></a> [oidc\_azure\_subscription\_id](#output\_oidc\_azure\_subscription\_id) | AZURE\_SUBSCRIPTION\_ID |
| <a name="output_oidc_azure_tenant_id"></a> [oidc\_azure\_tenant\_id](#output\_oidc\_azure\_tenant\_id) | AZURE\_TENAND\_ID |
