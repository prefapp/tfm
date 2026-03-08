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
