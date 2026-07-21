# Example: Destination (receiver) account for cross-account backup replication
#
# This module should be used in the AWS account that *receives* backup copies
# from another account. Set source_account_id to allow the source account
# to copy backups into this vault.

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

  region = "eu-west-1"

  aws_backup_vault = [{
    vault_name = "my-backup-vault"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "three" = "four"
    # }
    }
  ]
  source_account_id = "123456789012" # Source account ID that will copy backups into this vault
}
