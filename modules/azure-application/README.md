<!-- BEGIN_TF_DOCS -->
# `azure-application`

## Overview

Terraform module that registers an **Azure AD application** (`azuread_application`), configures **redirect URIs**, creates or links the **enterprise application** (`azuread_service_principal` with `use_existing = true`), optional **rotating client secret** (`time_rotating` + `azuread_application_password`) and **Key Vault** storage, **Microsoft Graph** delegated permissions (`required_resource_access`) and optional **Graph app role** assignments, **default access** assignments for listed members, **federated identity credentials** (workload identity / OIDC), and optional **Azure RBAC** assignments on ARM scopes for the service principal.

**Prerequisites**

- Terraform and provider versions in [`versions.tf`](versions.tf).
- Permissions to create app registrations, service principals, and related Graph operations in Microsoft Entra ID.
- Where **`client_secret.keyvault`** is set: `azurerm` access to the target Key Vault and permission to write secrets.
- Where **`extra_role_assignments`** is used: permission to create role assignments on each `scope`.
- Configure **`azuread`** and **`azurerm`** providers (tenant, subscription, authentication) in the root module.

**Behaviour notes (as implemented)**

- **`data.azurerm_client_config.current`** is declared in [`main.tf`](main.tf) but **not referenced** elsewhere (safe to remove in a future refactor if you want zero unused data sources).
- **`lifecycle.ignore_changes`** on `azuread_application.this` ignores `public_client`, `web`, and `single_page_application` drift.
- **`msgraph_roles`**: entries add **OAuth2 permission scopes** on the app (`required_resource_access`, `type = "Scope"`). Entries with **`delegated = true`** also get `azuread_app_role_assignment` against the Microsoft Graph service principal using `app_role_ids` keyed by `id` (must match a known Graph app role id string).
- **`members`**: `azuread_app_role_assignment.members` uses the **default user access** app role id `00000000-0000-0000-0000-000000000000` for each principal object id in the list.
- **`client_secret`**: when `enabled`, set **`rotation_days`** (required by `time_rotating`). Optional **`keyvault`** stores the generated password in `azurerm_key_vault_secret`.

## Basic usage

```hcl
module "app" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-application?ref=azure-application-v1.0.0"

  name = "example-app"

  redirects = [
    {
      platform      = "Web"
      redirect_uris = ["https://example.com/auth"]
    }
  ]

  members       = []
  msgraph_roles = []

  client_secret = {
    enabled = false
  }

  federated_credentials    = []
  extra_role_assignments   = []
}
```

Tune `members`, `msgraph_roles`, `federated_credentials`, and `extra_role_assignments` for your scenario.

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | App registration, SP, secrets, Graph/ARM assignments, federated credentials |
| `variables.tf` | Inputs |
| `outputs.tf` | Application IDs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

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
| <a name="input_msgraph_roles"></a> [msgraph\_roles](#input\_msgraph\_roles) | The list of Microsoft Graph roles to be assigned to the Azure App Registration. Each role includes a name and whether it is delegated. | <pre>list(object({<br/>    id        = string<br/>    delegated = bool<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure App Registration. | `string` | n/a | yes |
| <a name="input_redirects"></a> [redirects](#input\_redirects) | The redirect configuration for the Azure App Registration. | <pre>list(object({<br/>    platform      = string<br/>    redirect_uris = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | Application (client) ID of the app registration. |
| <a name="output_application_object_id"></a> [application\_object\_id](#output\_application\_object\_id) | Object ID of the app registration. |

## Generated README tables

With **terraform-docs** and `settings.lockfile: true`, **Requirements** shows provider constraints from `versions.tf` and **Providers** shows versions resolved from `.terraform.lock.hcl` at doc generation time.

## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-application/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-application/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf`)

Baseline versions: **`azuread`** `~> 3.3.0`, **`azurerm`** `~> 4.16.0`, **`time`** `~> 0.13.0`.

- [azuread\_application](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/application)
- [azuread\_application\_redirect\_uris](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/application_redirect_uris)
- [azuread\_service\_principal](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/service_principal)
- [azuread\_application\_password](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/application_password)
- [azuread\_app\_role\_assignment](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/app_role_assignment)
- [azuread\_application\_federated\_identity\_credential](https://registry.terraform.io/providers/hashicorp/azuread/3.3.0/docs/resources/application_federated_identity_credential)
- [azurerm\_key\_vault\_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/key_vault_secret)
- [azurerm\_role\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment)
- [time\_rotating](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/rotating)

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->