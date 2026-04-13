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
