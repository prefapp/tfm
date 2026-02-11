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
| <a name="output_user_assigned_identity_id"></a> [user_assigned_identity_id](#output\_user\_assigned\_identity\_id) | The ID of the User Assigned Identity. |

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