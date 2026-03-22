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
