<!-- BEGIN_TF_DOCS -->
# **GitHub Repository Terraform Module**

## Overview

This module provisions and configures a single GitHub repository with all standard settings (merge strategies, visibility, topics, auto-init, etc.) and sets the default branch using a single strongly-typed `config` object.

It is designed for Prefapp’s Internal Developer Platform and automated repository provisioning pipelines. The module accepts input directly from external programs via JSON (`terraform.tfvars.json` or `jsondecode`).

## Key Features

- **Single complex object**: All repository and default-branch settings live in one `config` variable.
- **Full GitHub repository settings**: Merge strategies, visibility, topics, auto-init, archive on destroy, etc.
- **Default branch management**: Automatic creation/renaming of the default branch.
- **JSON-native**: Perfect for programmatic generation from external systems.
- **Full validation**: Enforces required fields and valid values at plan time.
- **Clean outputs**: Every important value exposed as a separate output.

## Basic Usage

### Using `terraform.tfvars.json` (recommended)

```hcl
module "repository" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-repo"

  config = var.config   # Terraform automatically loads terraform.tfvars.json
}
```

### With teams, collaborators, and OIDC (inline configuration)

```hcl
module "repository" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-repo"

  config = {
    repository = {
      name        = "my-repo"
      description = "My repository"
      visibility  = "private"
      topics      = ["terraform", "iac"]
      autoInit    = true
    }

    default_branch = {
      branch = "main"
    }

    teams = [
      { teamId = 123456, permission = "push" },
      { teamId = 789012, permission = "maintain" },
    ]

    collaborators = [
      { username = "octocat", permission = "push" },
    ]

    oidc_subject_claim_customization_template = {
      useDefault       = false
      includeClaimKeys = ["repo", "ref", "job_workflow_ref"]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_repository_oidc_subject_claim_customization_template.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_oidc_subject_claim_customization_template) | resource |
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_branch_default.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborator.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) | resource |
| [github_repository_file.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub repository configuration (repository + default branch + files + variables + OIDC + teams + collaborators) as a single complex object | <pre>object({<br/>    repository = object({<br/>      name                = string<br/>      description         = optional(string, "")<br/>      visibility          = optional(string, "private")<br/>      topics              = optional(list(string), [])<br/>      autoInit            = optional(bool, false)<br/>      archiveOnDestroy    = optional(bool, false)<br/>      allowMergeCommit    = optional(bool, true)<br/>      allowSquashMerge    = optional(bool, true)<br/>      allowRebaseMerge    = optional(bool, true)<br/>      allowAutoMerge      = optional(bool, false)<br/>      deleteBranchOnMerge = optional(bool, false)<br/>      allowUpdateBranch   = optional(bool, false)<br/>      hasIssues           = optional(bool, true)<br/>    })<br/><br/>    default_branch = object({<br/>      branch     = string<br/>      rename     = optional(bool, false)<br/>    })<br/><br/>    files = optional(list(object({<br/>      branch            = string<br/>      commitMessage     = string<br/>      content           = string<br/>      file              = string<br/>      overwriteOnCreate = optional(bool, true)<br/>    })), [])<br/><br/>    variables = optional(list(object({<br/>      variableName = string<br/>      value        = string<br/>    })), [])<br/><br/>    oidc_subject_claim_customization_template = optional(object({<br/>      useDefault       = optional(bool, true)<br/>      includeClaimKeys = optional(list(string), [])<br/>    }), null)<br/><br/>    teams = optional(list(object({<br/>      teamId     = number      # Use numeric team ID to remain stable if team slugs change<br/>      permission = string<br/>    })), [])<br/><br/>    collaborators = optional(list(object({<br/>      username   = string<br/>      permission = string<br/>    })), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_added_teams"></a> [added\_teams](#output\_added\_teams) | List of teams (by ID) added to the repository |
| <a name="output_collaborators"></a> [collaborators](#output\_collaborators) | List of collaborators added to the repository |
| <a name="output_committed_files"></a> [committed\_files](#output\_committed\_files) | List of files that were committed |
| <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch) | Default branch name |
| <a name="output_oidc_subject_claim_customization_template"></a> [oidc\_subject\_claim\_customization\_template](#output\_oidc\_subject\_claim\_customization\_template) | OIDC subject claim customization template configuration |
| <a name="output_repository_full_name"></a> [repository\_full\_name](#output\_repository\_full\_name) | Full name (owner/repo) of the repository |
| <a name="output_repository_html_url"></a> [repository\_html\_url](#output\_repository\_html\_url) | URL to the repository on GitHub |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | ID of the created GitHub repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the created repository |
| <a name="output_repository_variables"></a> [repository\_variables](#output\_repository\_variables) | List of repository variables created |
| <a name="output_repository_visibility"></a> [repository\_visibility](#output\_repository\_visibility) | Visibility of the repository |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/gh-repo/_examples):

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->