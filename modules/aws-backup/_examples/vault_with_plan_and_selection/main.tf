# Example: Minimal KMS key creation

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
      name      = "only-rds-dayly-backup"
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
