# Example: Cross-region and cross-account AWS Backup setup
#
# This example shows a complete multi-account backup strategy:
#   1. Management account    – enables cross-account backup globally
#   2. Source account        – creates backup vault + plan, copies to DR account
#   3. Destination account   – receives copies from source account
#
# Prerequisites – KMS keys (use module aws-kms-multiple per account):
#
#   Source account (eu-south-2):
#     - Creates a "backup" KMS key in eu-south-2
#     - Replicates to eu-west-1
#     - Grants access to the destination account
#
#   Destination account (eu-west-1):
#     - Creates a "backup" KMS key in eu-west-1
#     - Grants access to the source account
#
# If you see "Cannot create a linked role for RDS backups", create an RDS
# instance in the destination account first so the RDS-linked service role is
# provisioned by AWS.

# ──────────────────────────────────────────────
# 1. Management account – enable cross-account backup
# ──────────────────────────────────────────────

module "backup_management" {
  source = "./../.."

  providers = {
    aws = aws.management
  }

  enable_cross_account_backup = true
}

# ──────────────────────────────────────────────
# 2. Source account – vault, plan, and cross-account copy
# ──────────────────────────────────────────────

module "backup_source" {
  source = "./../.."

  providers = {
    aws = aws.source
  }

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
    destination_account_id = "222222222222" # DR account
    destination_region     = "eu-west-1"
    delete_after           = 8
  }
}

# ──────────────────────────────────────────────
# 3. Destination account – receives copies
# ──────────────────────────────────────────────

module "backup_destination" {
  source = "./../.."

  providers = {
    aws = aws.destination
  }

  aws_kms_key_vault_arn = "arn:aws:kms:eu-west-1:222222222222:key/mrk-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

  aws_backup_vault = [{
    vault_name        = "common"
    vault_kms_key_arn = "arn:aws:kms:eu-west-1:222222222222:key/mrk-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }]

  source_account_id = "111111111111" # Source account that copies into this vault
}

# ──────────────────────────────────────────────
# Provider aliases (one per account)
# ──────────────────────────────────────────────

provider "aws" {
  alias  = "management"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "source"
  region = "eu-south-2"
}

provider "aws" {
  alias  = "destination"
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3"
    }
  }
}
