# **GitHub Files Set Terraform Module**

## Overview

This module creates or updates one or more files in a single GitHub repository using the `github_repository_file` resource.  
It is designed to be used in automated repository bootstrapping / golden-path workflows.

It accepts a list of files targeting one repository in a single `config` object — ideal for YAML/JSON input from external tools.

## Key Features

- Multiple files in one repository per module call
- Per-file branch, commit message, overwrite control within that repository
- **Provision-once semantics** for `userManaged = true` files: seeded once with default content, then never overwritten
- **`installed_managed_files` accumulator**: tracks which user-managed files have already been provisioned so callers can skip re-provisioning on subsequent reconciliations
- Native GitHub provider integration
- Input validation on required fields
- Stable outputs for downstream usage

## Basic Usage

```hcl
module "files" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-files-set"

  config = yamldecode(file("${path.module}/files.yaml"))
  # or jsondecode(...) if using JSON
}
```

## User-Managed Files

Files with `userManaged = true` are provisioned once with default content and then left entirely under user control. Terraform ignores subsequent content or commit-message drift on these files.

To enable provision-once behaviour across reconciliation cycles, pass the `installed_managed_files` list from the previous apply's output back as an input on the next apply:

```hcl
module "files" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-files-set"

  # Previously-provisioned addresses read from output secrets by gh_provisioner
  installed_managed_files = ["README.md/main", "CONTRIBUTING.md/main"]

  config = {
    repository = "my-org/my-repo"
    files = [
      {
        branch        = "main"
        commitMessage = "chore: seed CODEOWNERS"
        content       = "* @my-org/platform\n"
        file          = "CODEOWNERS"
        userManaged   = true
      }
    ]
  }
}
```

The `installed_managed_files` output is the **monotonically-growing union** of the input list and the addresses of any `userManaged = true` files present in the current `config.files`. It shrinks only when a file transitions from `userManaged = true` to `userManaged = false` — at that point Terraform resumes managing the file's content normally.

### Transition: `userManaged = true` → `userManaged = false`

Include the file in `config.files` with `userManaged = false`. On the next apply Terraform takes over content enforcement and the address is removed from `installed_managed_files`.

### Destroy behaviour

On feature deletion the caller (`gh_provisioner`) must remove all `github_repository_file.user_managed[*]` addresses from Terraform state before running destroy, so those files are preserved in the repository. Non-user-managed files are destroyed normally.
