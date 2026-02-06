# **AWS KMS MULTIPLE Terraform Module**

## Overview

This module leverages the aws-kms module to create multiple custom KMS keys in AWS. For each key specified in `kms_to_create`, an alias is automatically generated in the format "custom/$kms_to_create". The module also grants permissions for access from other accounts if required, and enables replication to additional regions.

## Key Features

- **Multiple KMS Keys**: Creates one KMS key per value in `kms_to_create`, each with an appropriate policy.
- **Automatic Alias Generation**: Assigns an alias in the format "custom/$kms_to_create" for each key and its replicas.
- **KMS Replication**: Replicates each KMS key to all configured regions.
- **Cross-Account Access**: Optionally grants access permissions to other AWS accounts.

## Basic Usage


### Minimal Example (multiple KMS keys with automatic alias)

```hcl
module "kms" {
  source         = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create  = [ { name = "rds" }, { name =  "s3" }, { name = "ec2" } ] # Each key will have alias "custom/<name>"
  aws_region     = "eu-west-1"
}
```

### With replication to other regions and cross-account access

```hcl
module "kms" {
  source              = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create       = [ { name = "rds" }, { name = "s3", kms_alias_prefix = "myneworg" }, { name = "ec2", via_service = ["ec2","lambda"] } ] # Aliases: custom/rds, myneworg/s3, custom/ec2
  aws_region          = "eu-west-1"
  aws_regions_replica = ["eu-central-1", "eu-west-2"] # Replicates each key to these regions
  aws_accounts_access = ["111111111111", "222222222222"] # Grants access to these AWS accounts
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── main.tf
├── variables.tf
├── _examples
│   ├── minimal
│   └── with_replication_account
├── README.md
└── docs
    └── header.md
```

- **main.tf**: Entry point that wires together all module components.

