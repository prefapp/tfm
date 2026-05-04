# **AWS BACKUP Terraform Module**

## Overview

This module provides a comprehensive configuration for AWS Backup, including vault creation, backup plans, resource selection, and advanced features such as cross-account and cross-region replication.

## Key Features

- **Vault**: Creates a vault to store backups.
- **Plan**: Creates backup plans with options to replicate backups to other vaults, including cross-account and cross-region replication.
- **Selections**: Allows selection of resources for backup using tags or by specifying the resource ARN.
- **Lambda**: Creates a Lambda function if the backup is copied to another account.
- **EventBridge**: Creates an EventBridge rule to trigger the Lambda function when a backup copy is finished (this is required to perform an additional copy to change the KMS encryption key).

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

**Note:** Cross-account backup only works with AWS Organizations. You must enable `cross_account_backup` in the organization's main account.

In the main account:
```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  enable_cross_account_backup  = true
}
```

For the accounts in your organization:

**In the account that only receives backups:**

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

**In the account that will make backups and send them to another account:**

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
├── CHANGELOG.md
├── docs
│   ├── footer.md
│   └── header.md
├── eventbridge.tf
├── _examples
│   ├── enable_cross_account
│   │   └── main.tf
│   ├── minimal
│   │   └── main.tf
│   ├── vault_with_plan_and_selection
│   │   └── main.tf
│   └── vault_with_plan_selection_with_replication
│       └── main.tf
├── iam-policy-roles.tf
├── lambda.tf
├── local.tf
├── main.tf
├── README.md
├── src
│   ├── common
│   │   ├── config.py
│   │   ├── handler.py
│   │   ├── __init__.py
│   │   ├── replication.py
│   │   └── utils.py
│   └── test_lambda.py
├── variables.tf
└── versions.tf
```

- **main.tf**: Entry point that wires together all module components. Here, vaults, plans, and selections are created.
- **iam-policy-roles.tf**: Policy document for AWS vaults.
- **backup-global-configuration.tf**: Configuration to enable cross-account backup in organizations.
- **eventbridge.tf**: Configuration to create the EventBridge trigger for Lambda.
- **lambda.tf**: Configuration to create the Lambda function for cross-account copy events.
- **src**: Folder containing the Lambda function code.
