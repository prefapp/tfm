# Azure OIDC

## Overview

This module creates an Azure AD application, service principal and role assignment for each application in the data file.

> Note: not defining a scope in an application is equivalent to defining the scope of the subscription

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

## Resources

| Name | Type |
|------|------|
| [azuread_application.gh_oidc_ad_app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.gh_oidc_identity_credential](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.gh_oidc_service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.gh_oidc_service_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-oidc?ref=<version>"
  data   = yamldecode(file("<path_to_yaml_file>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-oidc?ref=v1.2.3"
  data   = yamldecode(file("github_oidc.yaml")
```

### Set a data file

```yaml
organization: <organization_name> # In GitHub the organization is equivalent to a user account if it is not an organization
applications:
  - name: app
    roles:
      - role1
      - role2
    scope:
      - scope1
      - scope2
  - name: app2
    roles:
      - role1
```

#### Example

```yaml
organization: prefapp
applications:
  - name: service_repositories
    roles:
      - AcrPush
      - AcrPull
    scope:
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/bar/providers/Microsoft.ContainerRegistry/registries/bar-registries"
  - name: state_repositorie
    roles:
      - AcrPush
    scope:
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
  - name: infra_repositorie
    roles:
      - Contributor
    # scope:
    #   - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # This is similar to not putting scope
```
