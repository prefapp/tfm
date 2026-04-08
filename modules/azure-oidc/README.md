<!-- BEGIN_TF_DOCS -->
# Azure OIDC Terraform module (`azure-oidc`)

## Overview

This module provisions **Microsoft Entra ID (Azure AD)** resources for **OIDC / federated identity** scenarios (for example GitHub Actions → Azure):

- One **`azuread_application`** and **`azuread_service_principal`** per entry under **`data.applications`** (keyed by `name`).
- **`azuread_application_federated_identity_credential`** per federated credential (keyed by `app name` + `subject`).
- **`azurerm_role_assignment`** for each **role × scope** combination per application.

The input variable **`data`** is typically produced with **`yamldecode(file(...))`**. The YAML (or HCL object) **must** expose an **`applications`** list at the top level—this is what the module reads (`var.data.applications`). Older samples that used another root key (e.g. `app_registrations`) are **not** read by this module.

If an application **omits** `scope`, the module uses the **current subscription ID** from **`azurerm_subscription.primary`** for every role (same idea as assigning at subscription scope).

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | > 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.15.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | > 3.0.0 |

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
| <a name="input_data"></a> [data](#input\_data) | Configuration object (often from yamldecode). Must include `applications` (see module README). | `any` | n/a | yes |

## Outputs

No outputs.

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-oidc/_examples/basic) — Root module + `apps.yaml` with one application.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-oidc/_examples/comprehensive) — **`values.reference.yaml`**: fuller `applications` shape (illustrative).

## Remote resources

- **`azuread_application`**: [https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application)
- **`azuread_application_federated_identity_credential`**: [https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential)
- **`azurerm_role_assignment`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)
- **Workload identity federation (Microsoft)**: [https://learn.microsoft.com/entra/workload-id/workload-identity-federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
