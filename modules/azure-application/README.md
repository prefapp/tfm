<!-- BEGIN_TF_DOCS -->
# Azure Application (App Registration) Terraform module

## Overview

This Terraform module creates a **Microsoft Entra ID (Azure AD) application registration** (`azuread_application`), optional **redirect URIs**, a linked **enterprise application** (service principal), optional **Microsoft Graph API access** declared in `required_resource_access` (as OAuth2 **scopes**) plus optional **Graph `azuread_app_role_assignment`** when `msgraph_roles[*].delegated` is true, **default app role assignments** for listed members, optional **rotating client secrets** stored in **Key Vault**, **federated identity credentials** (for example workload federation / OIDC), and optional **Azure RBAC** role assignments for the service principal.

Use it when you want a single module to declare an app’s display name, redirect platforms, Graph API access, secrets, and related Azure assignments.

## Key features

- **App registration**: `azuread_application` with `requested_access_token_version = 2` and optional `required_resource_access` for Microsoft Graph when `msgraph_roles` is non-empty.
- **Redirect URIs**: One `azuread_application_redirect_uris` resource per element of `redirects` (indexed `for_each`), each with a `platform` of `PublicClient`, `SPA`, or `Web`. Because the resource is keyed by `application_id` and `type` (platform), supply **at most one list entry per platform** and put every URI for that platform in `redirect_uris` for that entry—do not repeat the same `platform` in multiple list items.
- **Enterprise app**: `azuread_service_principal` with `use_existing = true` tied to the registered application.
- **Members**: `azuread_app_role_assignment` for each object ID in `members` using the default app role (`00000000-0000-0000-0000-000000000000`).
- **Microsoft Graph**: Every entry adds Graph to `required_resource_access` with `type = Scope` and `id` from the input (OAuth2 **delegated permission scope id** on Microsoft Graph). If `delegated = true`, the module also creates `azuread_app_role_assignment` on Microsoft Graph using `lookup(data.azuread_service_principal.msgraph.app_role_ids, id)`; that lookup expects `id` to be a **key** in `app_role_ids` (provider: keys are Graph **app role value** strings), which may differ from the scope UUID used in `required_resource_access`—check the data source or plan output if the assignment does not resolve.
- **Client secret (optional)**: `time_rotating` + `azuread_application_password`, optionally written to `azurerm_key_vault_secret` when `client_secret.keyvault` is set.
- **Federated credentials**: `azuread_application_federated_identity_credential` from `federated_credentials`.
- **Azure RBAC (optional)**: `azurerm_role_assignment` from `extra_role_assignments`.

## Basic usage

Configure **AzureAD** and **AzureRM** in your root module (`azurerm` requires `features {}`). Provide `name`, `redirects`, `members`, and `msgraph_roles` (these lists may be empty when you do not need redirects, members, or Graph permissions yet).

When `client_secret.enabled` is `true`, set `client_secret.rotation_days` so `time_rotating` can schedule rotation.

### Minimal example

```hcl
module "azure_application" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-application?ref=<version>"

  name = "example-app-registration"

  redirects = [
    {
      platform      = "Web"
      redirect_uris = ["https://localhost/signin-oidc"]
    }
  ]

  members       = []
  msgraph_roles = []
}
```

For a fuller layout (optional secret, federated credentials, and RBAC), see `_examples/comprehensive`.

## Provisioner actor and permissions

The automation identity running Terraform needs sufficient **Microsoft Graph** and **Azure** permissions to manage applications, service principals, app role assignments, optional secrets, and optional Key Vault / role assignments. Exact roles depend on which optional features you enable; follow your tenant’s least-privilege guidelines.

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```

- **`main.tf`**: Application, redirects, service principal, optional secret rotation and Key Vault secret, Graph and member assignments, federated credentials, Azure role assignments.
- **`variables.tf` / `outputs.tf` / `versions.tf`**: Inputs, outputs, and provider version constraints.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
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
| <a name="input_msgraph_roles"></a> [msgraph\_roles](#input\_msgraph\_roles) | Microsoft Graph entries for this app. Each `id` is written to `azuread_application.required_resource_access` as `type = Scope` (use the OAuth2 delegated **permission scope id** / UUID for Microsoft Graph from the manifest or portal, not a display name). When `delegated` is true, the module also creates `azuread_app_role_assignment` on Microsoft Graph and sets `app_role_id` via `lookup(data.azuread_service_principal.msgraph.app_role_ids, id)`; that map is keyed by Graph **application role values** (per the AzureAD provider), which are not always the same string as the OAuth2 scope UUID—verify keys from the data source or `terraform plan` if assignments fail. When `delegated` is false, only the `required_resource_access` entry is created (no Graph app role assignment). | <pre>list(object({<br/>    id        = string<br/>    delegated = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure App Registration. | `string` | n/a | yes |
| <a name="input_redirects"></a> [redirects](#input\_redirects) | Redirect URIs per platform. The module creates one `azuread_application_redirect_uris` per list element (by index); each platform (`PublicClient`, `SPA`, `Web`) may appear only once—merge all URIs for a platform into a single object. | <pre>list(object({<br/>    platform      = string<br/>    redirect_uris = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | Application (client) ID of the app registration. |
| <a name="output_application_object_id"></a> [application\_object\_id](#output\_application\_object\_id) | Object ID of the app registration. |

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
<!-- END_TF_DOCS -->