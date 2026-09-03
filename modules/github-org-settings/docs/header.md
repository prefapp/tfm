# **GitHub Organization Settings Terraform Module**

## Overview

This module creates and manages the basic settings of a GitHub organization using the `github_organization_settings` Terraform resource. It is designed to be consumed by Firestartr `gh_provisioner` through a single strongly typed `config` object generated as `terraform.tfvars.json`.

The module centralizes organization profile fields, repository creation policies, project settings, member permissions, and default security settings for new repositories. It intentionally manages one organization settings resource so it maps cleanly to one Firestartr custom resource and one Terraform state.

This module does not create or delete a GitHub organization. It only updates settings for the organization configured in the GitHub provider.

## Key Features

- **gh-provisioner compatible**: Accepts one top-level `config` object suitable for generated `terraform.tfvars.json`.
- **Basic organization settings**: Manages billing email, company, blog, public email, location, display name, and description.
- **Repository creation policy**: Controls default repository permission and which repository types members can create.
- **Page and fork controls**: Manages Pages creation and private repository fork permissions.
- **Security defaults**: Configures Advanced Security, Dependabot, dependency graph, secret scanning, and push protection defaults for new repositories.

## Firestartr Compatibility

Expected generated input:

```json
{
  "config": {
    "billingEmail": "platform@example.com",
    "defaultRepositoryPermission": "read",
    "membersCanCreateRepositories": true
  }
}
```

The matching `gh_provisioner` entity should map the Firestartr CR spec to this `config` shape and use the Terraform address `github_organization_settings.this` for imports.

## Basic Usage

### Using `terraform.tfvars.json` (recommended for Firestartr)

```hcl
module "org_settings" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-settings"

  config = var.config
}
```

### Inline example

```hcl
module "org_settings" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-settings"

  config = {
    billingEmail                              = "platform@example.com"
    name                                      = "Example Organization"
    description                               = "Managed by Firestartr"
    defaultRepositoryPermission               = "read"
    membersCanCreateRepositories              = true
    membersCanCreatePublicRepositories        = false
    membersCanCreatePrivateRepositories       = true
    dependencyGraphEnabledForNewRepositories = true
    secretScanningEnabledForNewRepositories   = true
  }
}
```
