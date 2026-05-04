<!-- BEGIN_TF_DOCS -->
# **Azure User Assigned Managed Identity Terraform Module**

## Overview

This module creates an **Azure user-assigned managed identity** (`azurerm_user_assigned_identity`) in an existing resource group. It can attach **Azure RBAC role assignments** to arbitrary scopes, configure **federated identity credentials** for GitHub Actions, Kubernetes workload identity, or generic OIDC issuers, use **tags** from the resource group or from a `tags` map (not both at once), and grant **Key Vault access policies** for the identity on one or more vaults.

The module does **not** create the resource group, federated issuers, or Key Vaults; it wires the identity to resources you already manage.

## Key Features

- **User-assigned identity**: Name, location, and tags. When `tags_from_rg` is **true**, identity tags are **only** those on the resource group (`var.tags` is ignored). When **false**, tags come from `var.tags`.
- **RBAC**: `rbac` list flattens to `azurerm_role_assignment` entries (role name + scope per row).
- **Federated credentials**: `federated_credentials` entries share `audience`; each entry has `type` `github`, `kubernetes`, or `other` (validated). The variable marks nested fields optional, but **`main.tf` expects real values per type** or plan/apply can fail: **`github`** — set `organization`, `repository`, and `entity` (subject suffix, e.g. `ref:refs/heads/main`); `issuer` defaults to the GitHub Actions OIDC issuer if unset. **`kubernetes`** — set `issuer`, `namespace`, and `service_account_name`. **`other`** — set `issuer` and `subject`.
- **Key Vault access policies**: Optional `access_policies` to grant the identity permissions on existing vaults by `key_vault_id`.
- **Outputs**: Identity **`id`**, **`name`**, **`client_id`**, and **`principal_id`** for use in AKS, role assignments, or application configuration.

## Prerequisites

- Existing **resource group** (`resource_group`) and valid **Azure region** (`location`).
- **azurerm** provider configured for your subscription (`~> 4.16.0`; see `versions.tf`).
- For **federated credentials**, issuers and subjects must match your IdP or cluster configuration.
- For **role assignments**, the deploying principal needs permission to create assignments on each `scope`.

## Basic Usage

### Example (identity only, no RBAC or federated credentials)

```hcl
module "managed_identity" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name             = "uami-myapp-dev"
  resource_group   = "my-resource-group"
  location         = "westeurope"
  tags_from_rg     = false
  tags = {
    environment = "dev"
  }

  rbac                  = []
  federated_credentials = []
  access_policies       = []
}
```

### Example (RBAC role assignments)

```hcl
module "managed_identity_with_rbac" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name           = "uami-myapp-reader"
  resource_group = "my-resource-group"
  location       = "westeurope"
  tags_from_rg   = false
  tags           = {}

  rbac = [
    {
      name  = "rg-reader"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group"
      roles = ["Reader"]
    },
  ]

  federated_credentials = []
  access_policies       = []
}
```

Replace `scope` and role names with values valid in your tenant. See the [comprehensive example](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) for federated credential patterns.

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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | List of access policies for the Key Vault | <pre>list(object({<br/>    key_vault_id            = string<br/>    key_permissions         = optional(list(string), [])<br/>    secret_permissions      = optional(list(string), [])<br/>    certificate_permissions = optional(list(string), [])<br/>    storage_permissions     = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_audience"></a> [audience](#input\_audience) | The audience for the federated identity credential. | `list(string)` | <pre>[<br/>  "api://AzureADTokenExchange"<br/>]</pre> | no |
| <a name="input_federated_credentials"></a> [federated\_credentials](#input\_federated\_credentials) | A list of objects containing the federated credentials to assign to the User Assigned Identity. | <pre>list(object({<br/>    name                 = string<br/>    type                 = string<br/>    issuer               = optional(string)<br/>    namespace            = optional(string)<br/>    service_account_name = optional(string)<br/>    organization         = optional(string)<br/>    repository           = optional(string)<br/>    entity               = optional(string)<br/>    subject              = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the User Assigned Identity should be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | A list of objects containing the RBAC roles to assign to the User Assigned Identity. | <pre>list(object({<br/>    name  = string<br/>    scope = string<br/>    roles = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the Resource Group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the User Assigned Identity. | `map(string)` | <pre>{<br/>  "name": "value"<br/>}</pre> | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | If true, the User Assigned Identity will inherit the tags from the Resource Group. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The client ID (application ID) of the user-assigned managed identity. |
| <a name="output_id"></a> [id](#output\_id) | The Azure resource ID of the user-assigned managed identity. |
| <a name="output_name"></a> [name](#output\_name) | The name of the user-assigned managed identity. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The service principal object ID of the user-assigned managed identity (use for RBAC assignments referencing this identity). |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/basic) — Minimal user-assigned identity with empty `rbac`, `federated_credentials`, and `access_policies` (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) — Reference HCL and YAML for RBAC, federated GitHub/Kubernetes/OIDC credentials, and optional Key Vault access policies (`values.reference.yaml`; see folder README).

## Remote resources

Provider constraints for your workspace appear in the **Requirements** and **Providers** tables above. Resource documentation links below use the Terraform Registry **`latest`** path (see `versions.tf` for the module constraint, currently `~> 4.16.0`). Regenerate this README with `terraform-docs .` as described in [README.md generation](https://github.com/prefapp/tfm/blob/main/CONTRIBUTING.md#5-readmemd-generation).

- **Managed identities**: [https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/)
- **azurerm\_user\_assigned\_identity**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)
- **azurerm\_role\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)
- **azurerm\_federated\_identity\_credential**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential)
- **azurerm\_key\_vault\_access\_policy**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository's issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->