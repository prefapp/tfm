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
  region = "eu-west-1"
  aws_backup_vault = [{
    vault_name = "my-vault"
  }]
}
```


### Example with plan and tag selection

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  region = "eu-west-1"
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

### With replication to other regions and cross-account access

**Note:** Cross-account backup only works with AWS Organizations. You must enable `cross_account_backup` in the organization's main account.

In the main account:
```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  region                       = "eu-west-1"
  enable_cross_account_backup  = true
}
```

For the accounts in your organization:

**In the account that only receives backups:**

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  region = "eu-west-1"
  aws_backup_vault = [{
    vault_name = "only-rds-component-tags-backup"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "three" = "four"
    # }
    }
  ]
  source_account_id = "123456789012" # Source account ID that will copy backups into this vault
}
```

**In the account that will make backups and send them to another account:**

```hcl
module "backup" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  region = "eu-west-1"
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

## Cross-Region and Cross-Account Backup

This setup uses three AWS accounts working together:

1. **Management account** – enables the AWS Backup cross-account setting globally via `enable_cross_account_backup = true`. This is required for AWS Organizations.
2. **Source account** – contains the workloads to back up. Creates a backup vault, a backup plan with tag-based resource selection, and configures a copy action to replicate recovery points to the destination account/region.
3. **Destination account (DR)** – receives the backup copies. Creates a vault with `source_account_id` pointing to the source account so the Lambda can re-encrypt copies with the local KMS key.

Because copies cross account boundaries, the KMS keys must allow the remote account. Use the `aws-kms-multiple` module (see its examples) to create a multi-region KMS key per account and grant access to the peer account.

### KMS setup (source account)

```hcl
module "kms_source" {
  source = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create = [
    { name = "backup" }
  ]
  aws_region          = "eu-south-2"
  aws_regions_replica = ["eu-west-1"]
  aws_accounts_access = ["222222222222"] # DR account ID
}
```

### KMS setup (destination account)

```hcl
module "kms_destination" {
  source = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create = [
    { name = "backup" }
  ]
  aws_region          = "eu-west-1"
  aws_accounts_access = ["111111111111"] # Source account ID
}
```

### Management account – enable cross-account backup

```hcl
module "backup_management" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  enable_cross_account_backup = true
}
```

### Source account – vault, plan, and cross-account copy

```hcl
module "backup_source" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_kms_key_vault_arn = "arn:aws:kms:eu-south-2:111111111111:key/mrk-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  aws_backup_vault = [{
    vault_name        = "common"
    vault_kms_key_arn = "arn:aws:kms:eu-south-2:111111111111:key/mrk-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    plan = [{
      name      = "only-rds-daily-backup"
      rule_name = "rds-daily-backup"
      schedule  = "cron(0 0 * * ? *)"
      backup_selection_conditions = {
        string_equals = [
          { key = "aws:ResourceTag/aws_backup", value = "true" }
        ]
      }
    }]
  }]
  copy_action_default_values = {
    destination_account_id = "222222222222"
    destination_region     = "eu-west-1"
    delete_after           = 8
  }
}
```

### Destination account – receives copies

```hcl
module "backup_destination" {
  source = "github.com/prefapp/tfm/modules/aws-backup"
  aws_kms_key_vault_arn = "arn:aws:kms:eu-west-1:222222222222:key/mrk-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  aws_backup_vault = [{
    vault_name        = "common"
    vault_kms_key_arn = "arn:aws:kms:eu-west-1:222222222222:key/mrk-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }]
  source_account_id = "111111111111"
}
```

## Common Errors

### "Cannot create a linked role for RDS backups"

When AWS Backup tries to back up an RDS instance, it needs the `AWSServiceRoleForRDSBackup` linked service role. This role is only provisioned by AWS automatically when the first RDS instance is created in the account — you cannot create it manually.

**If you see this error in the destination (DR) account**, it means no RDS instance has ever been created there. To fix it, deploy (even temporarily) an RDS instance or whichever service you are backing up in the destination account. AWS will generate the required linked role automatically.

```bash
# Verify the role exists
aws iam get-role --role-name AWSServiceRoleForRDSBackup
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
│   ├── receiver_account
│   │   └── main.tf
│   ├── vault_with_plan_and_selection
│   │   └── main.tf
│   └── vault_with_plan_selection_with_replication
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
