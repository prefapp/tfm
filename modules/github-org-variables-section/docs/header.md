# **GitHub Organization Variables Terraform Module**

## Overview

This module manages GitHub Actions organization-level variables using the `github_actions_organization_variable` Terraform resource. It is designed to be consumed by Firestartr `gh_provisioner` through a single strongly-typed `config` object generated as `terraform.tfvars.json`.

The module supports all three visibility modes (`all`, `private`, `selected`) and resolves repository references by full name (e.g. `my-org/my-repo`) using the `github_repository` data source, so consumers do not need to provide numeric repository IDs. Removing a variable from the config cleanly destroys only that variable without affecting the broader organization.

This module manages organization-level GitHub Actions variables (not secrets). It maps cleanly to one Firestartr custom resource and one Terraform state.

## Key Features

- **gh-provisioner compatible**: Accepts one top-level `config` object suitable for generated `terraform.tfvars.json`.
- **All visibility modes**: Supports `all`, `private`, and `selected` visibility.
- **Repository name resolution**: Resolves `selectedRepositoryIds` from human-readable `owner/repo` names via `data.github_repository`.
- **Plan-time validation**: Variable names validated against `^[A-Za-z0-9_]+$` and visibility against the allowed enum.
- **Adoption tracking**: Outputs `managed_variables` (list of names) and `variable_ids` (name to resource ID map).

## Firestartr Compatibility

Expected generated input:

```json
{
  "config": {
    "variables": {
      "MY_VARIABLE": {
        "value": "some-value",
        "visibility": "all"
      },
      "SCOPED_VARIABLE": {
        "value": "scoped-value",
        "visibility": "selected",
        "selectedRepositoryIds": ["my-org/my-repo", "my-org/another-repo"]
      }
    }
  }
}
```

The matching `gh_provisioner` entity should map the Firestartr CR spec to this `config` shape and use the Terraform address `github_actions_organization_variable.this["VARIABLE_NAME"]` for imports.

## Basic Usage

### Using `terraform.tfvars.json` (recommended for Firestartr)

```hcl
module "org_variables" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-variables-section"

  config = var.config
}
```

### Inline example

```hcl
module "org_variables" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-org-variables-section"

  config = {
    variables = {
      "DEPLOY_ENV" = {
        value      = "production"
        visibility = "all"
      }
      "TEAM_CHANNEL" = {
        value      = "eng-alerts"
        visibility = "private"
      }
      "COMPONENT_OVERRIDE" = {
        value                 = "custom"
        visibility            = "selected"
        selectedRepositoryIds = ["my-org/frontend", "my-org/backend"]
      }
    }
  }
}
```
