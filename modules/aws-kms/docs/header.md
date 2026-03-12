# **AWS KMS Terraform Module**

## Overview

This module creates custom KMS keys in AWS, grants permissions for access from other accounts if necessary, and enables replication to other regions.

## Key Features

- **KMS**: Creates a KMS key with an appropriate policy.
- **KMS Replication**: Creates replication in the configured regions.
- **KMS Alias**: Creates an alias for the KMS key and for each replica in other regions.

## Basic Usage

### Minimal Example (KMS without alias)

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
}
```

### With alias and replication to other regions

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
  alias = "rds"
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
}
```

### With alias, replication to other regions, and access from other AWS accounts

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
  alias = "rds"
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
  aws_accounts_access = ["111111111111", "222222222222"]
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── data.tf
├── main.tf
├── variables.tf
├── _examples
│   ├── minimal
│   ├── with_alias_replication
│   └── with_alias_replication_account
├── README.md
└── docs
    └── header.md
```

- **main.tf**: Entry point that wires together all module components.
- **data.tf**: Policy document for KMS key and replication.

