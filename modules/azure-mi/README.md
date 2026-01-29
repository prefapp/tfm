<!-- BEGIN_TF_DOCS -->
# Azure Managed Identity Terraform Module

## Overview

This Terraform module allows you to create and manage a User Assigned Managed Identity in Azure, with support for:
- Custom RBAC role assignments.
- Federated credentials for GitHub, Kubernetes, or other issuers.
- Tag inheritance from the resource group.
- Flexible audience configuration for federated credentials.

## Main features
- Create a managed identity with custom tags and location.
- Assign multiple RBAC roles at different scopes.
- Add federated credentials for GitHub Actions, Kubernetes service accounts, or custom issuers.
- Realistic configuration example.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output\_user\_assigned\_identity\_id"></a> [user\_assigned\_identity\_id](#output\\_user\\_assigned\\_identity\\_id) | The ID of the User Assigned Identity. |

## Complete usage example

### HCL
```hcl
name = "xxx"
resource_group = "xxx"
location = "xxx"
tags = {
  foo = "bar"
}
# tags_from_rg = true # Will inherit the tags from the resource group exclusively
rbac = [
  {
    name = "foo"
    scope = "scope-foo"
    roles = [
      "xxx"
    ]
  },
  {
    name = "bar"
    scope = "scope-bar"
    roles = [
      "xxx",
      "yyy",
      "zzz"
    ]
  }
]

federated_credentials = [
  {
    name = "foo-github"
    type = "github"
    organization = "foo"
    repository = "bar"
    entity = "baz"
  },
  {
    name = "foo-kubernetes"
    type = "kubernetes"
    issuer = "https://kubernetes.default.svc.cluster.local"
    namespace = "foo"
    service_account_name = "bar"
  },
  {
    name = "other"
    type = "other"
    issuer = "https://example.com"
    subject = "other"
  }
]
```

### YAML
```yaml
name: xxx
resource_group_name: xxx
location: xxx
tags:
  foo: bar
# tags_from_rg: true # Will inherit the tags from the resource group exclusively
rbac:
  - name: foo
    scope: scope-foo
    roles:
      - xxx
  - name: bar
    scope: scope-bar
    roles:
      - xxx
      - yyy
      - zzz
federated_credentials:
  - name: foo-github
    type: github
    organization: foo
    repository: bar
    entity: baz
  - name: foo-kubernetes
    type: kubernetes
    issuer: https://kubernetes.default.svc.cluster.local
    namespace: foo
    service_account_name: bar
  - name: other
    type: other
    issuer: https://example.com
    subject: other
```

## Notes
- You can use `tags_from_rg` to inherit tags exclusively from the resource group.
- Federated credentials support GitHub Actions, Kubernetes, and custom issuers.
- RBAC assignments can be defined for multiple scopes and roles.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |

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
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | List of access policies for the Key Vault | <pre>list(object({<br/>    key_vault_id = string<br/>    key_permissions = optional(list(string), [])<br/>    secret_permissions = optional(list(string), [])<br/>    certificate_permissions = optional(list(string), [])<br/>    storage_permissions = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
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
| <a name="output_id"></a> [id](#output\_id) | # OUTPUTS SECTION User Assigned Identity |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/basic) - User-assigned managed identity with basic configuration.

## Resources and support

- [Official Azure Managed Identities documentation](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Terraform reference for azurerm\_user\_assigned\_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)
- [Community support](https://github.com/prefapp/terraform-modules/discussions)

Need help? Open an issue or join the Prefapp community.
<!-- END_TF_DOCS -->