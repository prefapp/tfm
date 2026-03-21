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

## Basic Usage

```hcl
module "files" {
  source = "git::https://github.com/prefapp/tfm.git//modules/gh-files-set"

  config = yamldecode(file("${path.module}/files.yaml"))
  # or jsondecode(...) if using JSON
}
```
