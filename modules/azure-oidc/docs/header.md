# Azure OIDC Terraform module (`azure-oidc`)

## Overview

This module provisions **Microsoft Entra ID (Azure AD)** resources for **OIDC / federated identity** scenarios (for example GitHub Actions → Azure):

- One **`azuread_application`** and **`azuread_service_principal`** per entry under **`data.applications`** (keyed by `name`).
- **`azuread_application_federated_identity_credential`** per federated credential (keyed by `app name` + `subject`).
- **`azurerm_role_assignment`** for each **role × scope** combination per application.

The input variable **`data`** is typically produced with **`yamldecode(file(...))`**. The YAML (or HCL object) **must** expose an **`applications`** list at the top level—this is what the module reads (`var.data.applications`). Older samples that used another root key (e.g. `app_registrations`) are **not** read by this module.

If an application **omits** `scope`, the module uses the **current subscription scope** from **`azurerm_subscription.primary`** for every role (that is, the subscription resource ID used for assigning at subscription scope).

## Key features

- **Multi-app**: `for_each` on application `name` (names must be unique).
- **Federated credentials**: optional `federated_credentials` list per app (`issuer`, `subject`).
- **RBAC**: `roles` × `scope` (or default subscription scope).

## Prerequisites

- **`azurerm`** (with **`features {}`**) and **`azuread`** configured in the **root** module that calls this module.
- Permissions to create app registrations, service principals, federated credentials, and role assignments.

## Basic usage

```hcl
module "github_oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-oidc?ref=<version>"

  data = yamldecode(file("${path.module}/apps.yaml"))
}
```

Where `apps.yaml` begins with:

```yaml
applications:
  - name: my-app
    roles:
      - Reader
    federated_credentials:
      - subject: "repo:org/repo:ref:refs/heads/main"
        issuer: "https://token.actions.githubusercontent.com"
```

## File structure

```
.
├── CHANGELOG.md
├── data.tf
├── oidc.tf
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
