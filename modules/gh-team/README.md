<!-- BEGIN_TF_DOCS -->
# **Github Team Terraform Module**

## Overview

This module creates custom KMS keys in AWS, grants permissions for access from other accounts if necessary, and enables replication to other regions.

## Key Features

- **KMS**: Creates a KMS key with an appropriate policy.
- **KMS Replication**: Creates replication in the configured regions.
- **KMS Alias**: Creates an alias for the KMS key and for each replica in other regions.

## Basic Usage

### Minimal Example (KMS without alias)

```hcl
module "gh-team" {
  source = "github.com/prefapp/tfm/modules/gh-team"
  aws_region = "eu-west-1"
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── data.tf
├── main.tf
├── variables.tf
├── _examples
├── README.md
└── docs
    └── header.md
```

- **main.tf**: Entry point that wires together all module components.
- **data.tf**: Policy document for KMS key and replication.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

## Inputs

## Outputs

## Examples

## Remote Resources

## Support
<!-- END_TF_DOCS -->
