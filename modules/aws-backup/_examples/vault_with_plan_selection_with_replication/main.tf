# Example: AWS Backup vault with plan, selection, and cross-region/cross-account replication
#
# For cross-region copy (same account): set destination_account_id to the same account ID.
# For cross-account copy (different account): set destination_account_id to the
# destination account ID, and add source_account_id in the destination account's module.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Source account: creates backups and replicates them to the destination account
module "backup" {
  source = "./../.."

  region = "eu-west-1"

  aws_backup_vault = [{
    vault_name = "only-rds-backup"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "tree" = "four"
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
    destination_account_id = "098765432109" # Destination (DR) account ID for cross-account copy
    destination_region     = "us-east-1"
    delete_after           = 8
  }
}
