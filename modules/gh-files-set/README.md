<!-- BEGIN_TF_DOCS -->
# **GitHub Files Set Terraform Module**

## Overview

This module creates or updates one or more files in GitHub repositories using the `github_repository_file` resource.  
It is designed to be used in automated repository bootstrapping / golden-path workflows.

It accepts a list of files in a single `config` object — ideal for YAML/JSON input from external tools.

## Key Features

- Multiple files in one module call
- Per-file branch, commit message, overwrite control
- Native GitHub provider integration
- Input validation on required fields
- Clean outputs for downstream usage

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
| [github_repository_file.files](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | Configuration for multiple GitHub repository files to be created/updated | <pre>object({<br/>    files = list(object({<br/>      branch            = string<br/>      commitMessage     = string<br/>      content           = string<br/>      file              = string<br/>      repository        = string<br/>      overwriteOnCreate = optional(bool, true)<br/>      lifecycle         = optional(any, {})   # placeholder for future extensions<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_commit_messages"></a> [commit\_messages](#output\_commit\_messages) | Commit messages that were used |
| <a name="output_committed_files"></a> [committed\_files](#output\_committed\_files) | List of files that were successfully managed |
| <a name="output_file_paths"></a> [file\_paths](#output\_file\_paths) | Flat list of managed file paths (repo/path) |

### 5. `docs/footer.md`

```markdown
## Examples

See [_examples/basic](https://github.com/prefapp/tfm/tree/main/modules/gh-files-set/_examples/basic)

## Resources

- **github_repository_file**  
  https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file

## Support

Open issues in https://github.com/prefapp/tfm/issues
```
<!-- END_TF_DOCS -->