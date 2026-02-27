# Example: AWS Backup vault with plan, selection, and cross-region replication

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

module "backup-cross-region" {
  source = "./../.."
  aws_backup_vault = [{
    vault_name   = "only-rds-backup"
    vault_region = "us-east-1"
  }]

}
module "backup" {
  source = "./../.."

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
    destination_account_id = "123456789012" # Same account id for cross-region copy, different account id for cross-account copy
    destination_region     = "us-east-1"
    delete_after           = 8
  }
}
