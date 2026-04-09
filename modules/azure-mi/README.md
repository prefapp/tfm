<!-- BEGIN_TF_DOCS -->
# Azure user-assigned managed identity (`azure-mi`)

## Overview

This module creates a **user-assigned managed identity** (`azurerm_user_assigned_identity`) and can attach:

- **RBAC role assignments** (`azurerm_role_assignment`) from a flattened `name` / `scope` / `roles` list
- **Federated identity credentials** (`azurerm_federated_identity_credential`) for GitHub Actions, Kubernetes workload identity, or custom issuers (`type`: `github`, `kubernetes`, `other`)
- **Key Vault access policies** (`azurerm_key_vault_access_policy`) when `access_policies` is non-empty

Tags: if `tags_from_rg` is **`true`**, tags come from the resource group data source; otherwise **`tags`** are used (default **`{}`**).

## Federated credentials

| `type` | Behaviour |
|--------|-----------|
| `github` | `issuer` defaults to `https://token.actions.githubusercontent.com` if omitted. `subject` is `repo:{organization}/{repository}:{entity}`; if `entity` is omitted it defaults to `ref:refs/heads/main`. |
| `kubernetes` | `subject` is `system:serviceaccount:{namespace}:{service_account_name}`. |
| `other` | You must set `issuer` and `subject`. |

`audience` applies to all federated credentials (default `["api://AzureADTokenExchange"]`).

## Key Vault access policies

Each object in `access_policies` becomes one policy. The module keys policies by `key_vault_id`, so **at most one entry per Key Vault** in the list.

## Prerequisites

- Existing **resource group** (`resource_group`).
- **azurerm** provider configured.

## Basic usage

```hcl
module "mi" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name           = "example-mi"
  resource_group = "example-rg"
  location       = "westeurope"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  rbac = [
    {
      name  = "sub-contributor"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      roles = ["Reader"]
    }
  ]

  federated_credentials = []
  access_policies       = []
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── variables.tf
├── versions.tf
├── outputs.tf
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.that](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault_access_policy.access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_role_assignment.that](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Key Vault access policies for this identity (one object per key\_vault\_id). | <pre>list(object({<br/>    key_vault_id = string<br/>    key_permissions = optional(list(string), [])<br/>    secret_permissions = optional(list(string), [])<br/>    certificate_permissions = optional(list(string), [])<br/>    storage_permissions = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_audience"></a> [audience](#input\_audience) | Audience list passed to every federated identity credential. | `list(string)` | <pre>[<br/>  "api://AzureADTokenExchange"<br/>]</pre> | no |
| <a name="input_federated_credentials"></a> [federated\_credentials](#input\_federated\_credentials) | Federated identity credentials (GitHub Actions, Kubernetes, or custom issuer/subject). | <pre>list(object({<br/>    name                 = string<br/>    type                 = string<br/>    issuer               = optional(string)<br/>    namespace            = optional(string)<br/>    service_account_name = optional(string)<br/>    organization         = optional(string)<br/>    repository           = optional(string)<br/>    entity               = optional(string)<br/>    subject              = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the identity. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the user-assigned managed identity. | `string` | n/a | yes |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | RBAC blocks: each entry expands to one role assignment per role in roles. | <pre>list(object({<br/>    name  = string<br/>    scope = string<br/>    roles = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group name where the identity is created (must exist). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the identity when tags\_from\_rg is false. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | If true, use tags from the resource group data source instead of var.tags. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the user-assigned managed identity. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/basic) — Managed identity with RBAC only.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) — **`values.reference.yaml`**: RBAC, federated credentials, and optional Key Vault policies.

## Remote resources

- **Terraform `azurerm_user_assigned_identity`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)
- **Terraform `azurerm_role_assignment`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)
- **Terraform `azurerm_federated_identity_credential`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential)
- **Terraform `azurerm_key_vault_access_policy`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->