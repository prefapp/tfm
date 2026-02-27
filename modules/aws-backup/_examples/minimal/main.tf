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
    vault_name = "my-vault"
    # vault_region = "eu-west-1"
    # vault_tags = {
    #   "one"  = "two"
    #   "tree" = "four"
    # }
    }
  ]
}
