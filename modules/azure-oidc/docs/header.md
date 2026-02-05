# Azure OIDC Terraform Module

## Overview

This Terraform module creates Azure AD applications, service principals, and role assignments for each application defined in the input data file. It supports federated credentials for GitHub Actions and other issuers.

> Note: Not defining a scope in an application is equivalent to defining the scope of the subscription.

## Main features
- Create multiple Azure AD applications and service principals.
- Assign custom roles and scopes to each application.
- Add federated credentials for GitHub Actions or custom issuers.
- Realistic configuration example.

## Complete usage example

### Module usage
```hcl
module "github-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-oidc?ref=<version>"
  data   = yamldecode(file("<path_to_yaml_file>"))
}
```

### Example data file
```yaml
applications:
  - name: app
    roles:
      - role1
      - role2
    scope:
      - scope1
      - scope2
    federated_credentials:
      - subject: "subject_claim_foo:my_repo_foo"
        issuer: "issuer_foo"
      - subject: "subject_claim_bar:my_repo_bar"
        issuer: "issuer_bar"
  - name: app2
    roles:
      - role1
    federated_credentials:
      - subject: "my_repo_foo_foo"
        issuer: "issuer_foo_foo"
```

#### Realistic example
```yaml
app_registrations:
  - name: service_repositories
    roles:
      - AcrPush
      - AcrPull
    scope:
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/bar/providers/Microsoft.ContainerRegistry/registries/bar-registries"
    federated_credentials:
      - subject: "repository_owner:prefapp"
        issuer: "https://token.actions.githubusercontent.com"
  - name: state_repositorie
    roles:
      - AcrPush
    scope:
      - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
    federated_credentials:
      - subject: "repository_owner:prefapp"
        issuer: "https://token.actions.githubusercontent.com"
  - name: infra_repositorie
    roles:
      - Contributor
    federated_credentials:
      - subject: "my_repo_foo"
        issuer: "issuer_foo"
      - subject: "my_repo_bar"
        issuer: "issuer_bar"
    # scope:
    #   - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # This is similar to not putting scope
```

## Notes
- If you do not define a scope, the subscription scope will be used by default.
- Federated credentials support GitHub Actions and custom issuers.
- Each application can have multiple roles, scopes, and federated credentials.

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