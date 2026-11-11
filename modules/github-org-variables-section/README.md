<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_actions_organization_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_repository.selected](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_config"></a> [config](#input\_config) | Complete configuration object for this module.<br/><br/>variables = map of variable\_name => { value, visibility, selectedRepositoryIds }<br/><br/>- variable\_name (map key): GitHub Actions organization variable name. Must match ^[A-Za-z0-9\_]+$.<br/>- value: The value of the variable.<br/>- visibility: Must be one of 'all', 'private', or 'selected'.<br/>- selectedRepositoryIds: Optional list of repository full names (owner/repo) to scope the variable to when visibility is 'selected'. Ignored for other visibility modes. | <pre>object({<br/>    variables = map(object({<br/>      value                 = string<br/>      visibility            = string<br/>      selectedRepositoryIds = optional(list(string))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_managed_variables"></a> [managed\_variables](#output\_managed\_variables) | List of managed organization variable names. |
| <a name="output_variable_ids"></a> [variable\_ids](#output\_variable\_ids) | Map of variable names to their resource IDs. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-variables-section/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-variables-section/_examples/basic) - Full example covering all three visibility modes through a `config.json` file.

## Resources

- **github\_actions\_organization\_variable**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable)
- **github\_repository** (data source): [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Import Behavior

This module manages `github_actions_organization_variable` resources via `for_each` over the `variables` map.

- Terraform address: `github_actions_organization_variable.this["VARIABLE_NAME"]`
- Import ID: the variable name (e.g. `MY_VARIABLE`)

The variable name can be discovered from the GitHub REST API or the GitHub Actions organization variables UI. Firestartr `gh_provisioner` should import using the variable name when adopting existing organization variables.

## Delete Behavior

`terraform destroy` deletes the managed organization variables from GitHub Actions. This affects only the variable entries defined in `config.variables`. Removing a single variable from the config safely destroys only that variable; other variables and broader organization settings are unaffected.

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->