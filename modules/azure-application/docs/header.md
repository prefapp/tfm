# Azure Application (App Registration) Terraform module

## Overview

This Terraform module creates a **Microsoft Entra ID (Azure AD) application registration** (`azuread_application`), optional **redirect URIs**, a linked **enterprise application** (service principal), optional **Microsoft Graph API access** declared in `required_resource_access` (as OAuth2 **scopes**) plus optional **Graph `azuread_app_role_assignment`** when `msgraph_roles[*].delegated` is true, **default app role assignments** for listed members, optional **rotating client secrets** stored in **Key Vault**, **federated identity credentials** (for example workload federation / OIDC), and optional **Azure RBAC** role assignments for the service principal.

Use it when you want a single module to declare an app’s display name, redirect platforms, Graph API access, secrets, and related Azure assignments.

## Key features

- **App registration**: `azuread_application` with `requested_access_token_version = 2` and optional `required_resource_access` for Microsoft Graph when `msgraph_roles` is non-empty.
- **Redirect URIs**: Separate `azuread_application_redirect_uris` resources per platform (`PublicClient`, `SPA`, or `Web`), validated on the `redirects` input.
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
