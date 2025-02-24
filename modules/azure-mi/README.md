## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.16.0 |

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
| name | The name of the Managed Identity | `string` | n/a | yes |
| resource_group | The name of the resource group in which to create the Managed Identity | `string` | n/a | yes |
| location | The location in which to create the Managed Identity | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource | `map(string)` | n/a | no |
| tags_from_rg | If true, the tags from the resource group will be inherited exclusively | `bool` | `false` | no |
| rbac | A list of role-based access control (RBAC) policies to apply to the Managed Identity | <pre>list(object({<br> name: string (required)<br> scope: string (required)<br> roles: list(string) (required)<br>}))</pre> | n/a | yes |
| federated_credentials | A list of federated credentials to assign to the Managed Identity, posible types are:<br><br>**kubernetes**: `issuer`, `namespace` and `service_account_name`<br>- `issuer`: The cluster issuer<br>- `namespace`: The namespace of the service account<br>- `service_account_name`: The name of the service account<br><br>**github**: `issuer`, `organization`, `repository` and `entity`<br>- `issuer`: The github issuer<br>- `organization`: The github organization<br>- `repository`: The github repository<br>- `entity`: The github entity \|Optional value, if not provided, the entity will be the repository. For other scenarios, the entity should be provided:<br>&nbsp;&nbsp;- environment: `environment:foo_enviroment`<br>&nbsp;&nbsp;- tags: `ref:refs/tags/foo_tag`<br>&nbsp;&nbsp;- branch: `ref:refs/heads/foo_branch`<br>&nbsp;&nbsp;- commit: `ref:refs/commits/foo_commit`<br><br>**other**: `issuer` and `subject`<br>- `issuer`: The issuer<br>- `subject`: The subject | <pre>list(object({<br> name: string (required)<br> type: string (required) - **kubernetes** \|\| **github** \|\| **other**<br> issuer: string (required only when type is **kubernetes** or **other**, when type is **github** is optional because the default is `https://token.actions.githubusercontent.com`)<br> namespace: string (required only when the type is **kubernetes**)<br> service_account_name: string (required only when the type is **kubernetes**)<br> organization: string (required only when the type is **github**)<br> repository: string (required only when the type is **github**)<br> entity: string (required only when the type is **github** and the entity is not the repository)<br> subject: string (required only when the type is **other**)<br>}))</pre> | `[]` | no |
| audience | The audience of the federated identity credential | `list(string)` | `["api://AzureADTokenExchange"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_assigned_identity_id"></a> [user_assigned_identity_id](#output\_user\_assigned\_identity\_id) | The ID of the User Assigned Identity. |

## Example

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

### Yaml
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
