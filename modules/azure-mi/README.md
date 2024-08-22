## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.113.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html) | data resource (only when `tags from resource group` is enabled) |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | source |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/role_assignment) | source |
| [azurerm_federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | source (only when `federated_credentials` is not empty) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Key Vault | `string` | n/a | yes |
| resource_group | The name of the resource group in which to create the Key Vault | `string` | n/a | yes |
| location | The location of the resource group in which to create the Key Vault | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource | `map(string)` | n/a | no |
| tags_from_rg | If true, the tags from the resource group will be inherited exclusively | `bool` | `false` | no |
| rbac | A list of role-based access control (RBAC) policies to apply to the Key Vault | <pre>list(object({<br>    name  = string<br>    scope = string<br>    roles = list(string)<br>  }))</pre> | n/a | yes |
| federated_credentials | A list of federated credentials to assign to the Key Vault | <pre>list(object({<br>    name                 = string<br>    type                 = string<br>    issuer               = string<br>    namespace            = optional(string)<br>    service_account_name = optional(string)<br>    organization         = optional(string)<br>    repository           = optional(string)<br>    entity               = optional(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_assigned_identity_id"></a> [user_assigned_identity_id](#output\_user\_assigned\_identity\_id) | The ID of the User Assigned Identity. |

## Example

```yaml
name: xxx
resource_group_name: xxx
location: xxx
tags:
  foo: bar
# tags_from_rg: true # Will inherit the tags from the resource group exclusively
rbac: # 1-n
  - name: foo
    scope: scope-foo
    roles:
      - xxx
  - name: bar
    scope: scope-bar
    roles: # 1-n
      - xxx
      - yyy
      - zzz
federated_credentials: # {} | 0-20
   - name: foo-K8s
     type: K8s # subject like: system:serviceaccount:<namespace>:<serviceaccount>
     issuer: xxx
     namespace: xxx
     service_account_name: xxx
   - name: bar-github
     type: github # subject like: repo:{Organization}/{Repository}:{Entity}
     issuer: xxx
     organization: xxx
     repository: xxx
     entity: xxx
```
