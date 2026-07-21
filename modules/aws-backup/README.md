<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.3 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.3 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_lambda_automatic_replication"></a> [lambda\_automatic\_replication](#module\_lambda\_automatic\_replication) | terraform-aws-modules/lambda/aws | 8.7 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_backup_global_settings.global](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_global_settings) | resource |
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.resource_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.tag_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_cloudwatch_event_rule.rds_backup_job_completed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_copy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowed_assume_roles"></a> [allowed\_assume\_roles](#input\_allowed\_assume\_roles) | List of IAM roles the Lambda can assume for cross-account replication | `list(string)` | `[]` | no |
| <a name="input_aws_backup_vault"></a> [aws\_backup\_vault](#input\_aws\_backup\_vault) | List of objects defining the backup vault configuration, including backup plans and replication rules. | <pre>list(object({<br/>    vault_name        = string<br/>    vault_region      = optional(string)<br/>    vault_tags        = optional(map(string))<br/>    vault_kms_key_arn = optional(string)<br/><br/>    plan = optional(list(object({<br/>      name                         = string<br/>      rule_name                    = string<br/>      schedule                     = string<br/>      schedule_expression_timezone = optional(string)<br/>      start_window                 = optional(number)<br/>      completion_window            = optional(number)<br/>      # Structure for dynamic conditions in aws_backup_selection<br/>      # Example usage:<br/>      # backup_selection_conditions = {<br/>      #   string_equals = [<br/>      #     { key = "aws:ResourceTag/Component", value = "rds" }<br/>      #   ]<br/>      #   string_like = [<br/>      #     { key = "aws:ResourceTag/Application", value = "app*" }<br/>      #   ]<br/>      #   string_not_equals = [<br/>      #     { key = "aws:ResourceTag/Backup", value = "false" }<br/>      #   ]<br/>      #   string_not_like = [<br/>      #     { key = "aws:ResourceTag/Environment", value = "test*" }<br/>      #   ]<br/>      # }<br/>      backup_selection_conditions = optional(object({<br/>        string_equals     = optional(list(object({ key = string, value = string })))<br/>        string_like       = optional(list(object({ key = string, value = string })))<br/>        string_not_equals = optional(list(object({ key = string, value = string })))<br/>        string_not_like   = optional(list(object({ key = string, value = string })))<br/>      }))<br/>      backup_selection_arn_resources = optional(list(string))<br/>      lifecycle = optional(object({<br/>        cold_storage_after = optional(number)<br/>        delete_after       = number<br/>      }))<br/>      advanced_backup_setting = optional(list(object({<br/>        backup_options = map(string)<br/>        resource_type  = string<br/>      })))<br/>      scan_action = optional(list(object({<br/>        malware_scanner  = string<br/>        scan_action_type = string<br/>      })))<br/>      recovery_point_tags = optional(map(string))<br/>      tags                = optional(map(string))<br/>      copy_action = optional(list(object({<br/>        destination_vault_arn = string<br/>        delete_after          = optional(number)<br/>      })))<br/>      })<br/>    ))<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_aws_kms_key_vault_arn"></a> [aws\_kms\_key\_vault\_arn](#input\_aws\_kms\_key\_vault\_arn) | ARN of the KMS key used to encrypt the backup vault. If not provided, the default AWS Backup vault encryption will be used. | `string` | `null` | no |
| <a name="input_copy_action_default_values"></a> [copy\_action\_default\_values](#input\_copy\_action\_default\_values) | Default values for the copy action configuration in backup plan rules. If not provided, the copy action will not be created. | <pre>object({<br/>    destination_account_id = string<br/>    destination_region     = string<br/>    delete_after           = number<br/>  })</pre> | <pre>{<br/>  "delete_after": 14,<br/>  "destination_account_id": null,<br/>  "destination_region": null<br/>}</pre> | no |
| <a name="input_enable_cross_account_backup"></a> [enable\_cross\_account\_backup](#input\_enable\_cross\_account\_backup) | Enable cross-account backup in AWS Backup global settings. If set to true, the module will manage the global settings resource to enable cross-account backup. If set to false, you can configure it separately if needed. | `bool` | `false` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Lambda memory in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `600` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the Lambda function for cross-account replication will be created. | `string` | `"eu-west-1"` | no |
| <a name="input_source_account_id"></a> [source\_account\_id](#input\_source\_account\_id) | Account id that copies backups into this vault | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-backup/_examples):

- [Minimal](https://github.com/prefapp/tfm/tree/main/modules/aws-backup/_examples/minimal) – Minimal vault creation
- [Vault with plan and selection](https://github.com/prefapp/tfm/tree/main/modules/aws-backup/_examples/vault\_with\_plan\_and\_selection) – Backup vault creation with configuration of plans and backup selections
- [Vault with plan, selection, and replication](https://github.com/prefapp/tfm/tree/main/modules/aws-backup/_examples/vault\_with\_plan\_selection\_with\_replication) – KMS key creation with alias, cross-region replication, and additional account access
- [Cross-region and cross-account backup](https://github.com/prefapp/tfm/tree/main/modules/aws-backup/_examples/cross-region-and-account) – Full multi-account backup strategy: management, source, and destination accounts

## Remote Resources
- Terraform: https://www.terraform.io/
- Amazon AWS Backup: [https://aws.amazon.com/es/backup/](https://aws.amazon.com/es/backup/)
- Terraform AWS Provider: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->