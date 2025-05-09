## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.msgraph_roles](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_password.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_application_redirect_uris.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_redirect_uris) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.extra_role_assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [time_rotating.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | The client secret configuration for the Azure App Registration. | <pre>object({<br/>    enabled       = bool<br/>    rotation_days = optional(number)<br/>    keyvault = optional(object({<br/>      id       = string<br/>      key_name = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "keyvault": null<br/>}</pre> | no |
| <a name="input_extra_role_assignments"></a> [extra\_role\_assignments](#input\_extra\_role\_assignments) | The list of extra role assignments to be added to the Azure App Registration. | <pre>list(object({<br/>    role_definition_name = string<br/>    scope                = string<br/>  }))</pre> | `[]` | no |
| <a name="input_federated_credentials"></a> [federated\_credentials](#input\_federated\_credentials) | The federated credentials configuration for the Azure App Registration. | <pre>list(object({<br/>    display_name = string<br/>    audiences    = list(string)<br/>    issuer       = string<br/>    subject      = string<br/>    description  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_members"></a> [members](#input\_members) | The list of members to be added to the Azure App Registration. | `list(string)` | n/a | yes |
| <a name="input_msgraph_roles"></a> [msgraph\_roles](#input\_msgraph\_roles) | The list of Microsoft Graph roles to be assigned to the Azure App Registration. e.g. User.Read.All | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure App Registration. | `string` | n/a | yes |
| <a name="input_redirects"></a> [redirects](#input\_redirects) | The redirect configuration for the Azure App Registration. | <pre>list(object({<br/>    platform      = string<br/>    redirect_uris = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID of the Azure application |
| <a name="output_application_object_id"></a> [application\_object\_id](#output\_application\_object\_id) | The object ID of the Azure application |
