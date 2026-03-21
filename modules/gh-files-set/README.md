<!-- BEGIN_TF_DOCS -->
# **GitHub Files Set Terraform Module**

## Overview

This module creates or updates one or more files in a single GitHub repository using the `github_repository_file` resource.  
It is designed to be used in automated repository bootstrapping / golden-path workflows.

It accepts a list of files targeting one repository in a single `config` object — ideal for YAML/JSON input from external tools.

## Key Features

- Multiple files in one repository per module call
- Per-file branch, commit message, overwrite control within that repository
- Native GitHub provider integration
- Input validation on required fields
- Clean outputs for downstream usage
- User-managed files are provisioned once and **preserved on `terraform destroy`** — the Terraform state entry is removed but the actual file in GitHub is left untouched

## User-Managed Files

Files with `userManaged: true` are created via the GitHub API and **never deleted by Terraform**. When `terraform destroy` runs, the state entry is removed but the file in GitHub is preserved.

> **Note**: User-managed file provisioning requires the `GITHUB_TOKEN` environment variable to be set (the same token used to configure the GitHub provider).

## Basic Usage

```hcl
module "files" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-files-set"

  config = yamldecode(file("${path.module}/files.yaml"))
  # or jsondecode(...) if using JSON
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | built-in |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_repository_file.managed](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [terraform_data.user_managed](https://developer.hashicorp.com/terraform/language/resources/terraform-data) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | GitHub files configuration — userManaged files are provisioned once and survive destroy | <pre>object({<br/>    files = list(object({<br/>      branch            = string<br/>      commitMessage     = string<br/>      content           = string<br/>      file              = string<br/>      overwriteOnCreate = optional(bool, true)<br/>      userManaged       = optional(bool, false)<br/>    }))<br/><br/>    repository = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_managed_files"></a> [user\_managed\_files](#output\_user\_managed\_files) | Files marked as userManaged in the config (intended to be managed outside this module) |

## Examples

See [\_examples/basic](https://github.com/prefapp/tfm/tree/main/modules/gh-files-set/_examples/basic)

## Resources

- **github\_repository\_file**  
  https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file

- **terraform\_data**  
  https://developer.hashicorp.com/terraform/language/resources/terraform-data

## Support

Open issues in https://github.com/prefapp/tfm/issues
<!-- END_TF_DOCS -->