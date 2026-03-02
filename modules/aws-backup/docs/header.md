# **AWS BACKUP Terraform Module**

## Overview

This module provides configuration for AWS Backup, including vault creation, backup plans, and resource selection. 

## Key Features

- **Vault**: Creates a vault to store backups.
- **Plan**: Creates backup plans with options to replicate backups to other vaults, including cross-account and cross-region replication.
- **Selections**: Allows selection of resources for backup using tags or specifying the resource ARN. 

## Basic Usage

### Minimal Example (Creates only a vault to store backups; this option does not perform backups!)

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_backup_vault = [{
    vault_name = "my-vault"
  }]
}
```

### Example with plan and tag selection

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_backup_vault = [{
    vault_name = "only-rds-component-tags-backup"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "three" = "four"
    # }
    plan = [{
      name      = "only-rds-daily-backup"
      rule_name = "my-rule"
      schedule  = "cron(0 12 * * ? *)"
      backup_selection_conditions = {
        string_equals = [
          { key = "aws:ResourceTag/Component", value = "rds" }
        ]
      }
    }]
    }
  ]
}
```

### With alias, replication to other regions, and access from other AWS accounts

/!\ Important: Only works with aws organizations, you need to enable cross_account_backup in organization main account 


This only works in organization main account
```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"

  enable_cross_account_backup  = true
}
```

For the accounts in your organization

In the account that only receive backups:

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_backup_vault = [{
    vault_name = "only-rds-component-tags-backup"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "three" = "four"
    # }
    }
  ]
}
```

In the account that will make backups and send them to another account

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_backup_vault = [{
    vault_name = "only-rds-component-tags-backup"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "three" = "four"
    # }
    plan = [{
      name      = "only-rds-daily-backup"
      rule_name = "my-rule"
      schedule  = "cron(0 12 * * ? *)"
      backup_selection_conditions = {
        string_equals = [
          { key = "aws:ResourceTag/Component", value = "rds" }
        ]
      }
    }]
    }
  ]
  copy_action_default_values = {
    destination_account_id = "098765432109"
    destination_region = "eu-west-1"
    delete_after = 7
  }
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── backup-global-configuration.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── minimal
│   │   └── main.tf
│   ├── vault_with_plan_and_selection
│   │   └── main.tf
│   └── vault_with_plan_selection_with_replication
│       └── main.tf
├── iam-policy-roles.tf
├── main.tf
└── variables.tf
```

- **main.tf**: Entry point that wires together all module components, here they create vaults, plans and selections. 
- **iam-policy-roles.tf**: Policy document for aws vaults.
- **backup-global-configuration.tf**: Configuration for enable cross account backup in organizations. 


