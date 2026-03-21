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
