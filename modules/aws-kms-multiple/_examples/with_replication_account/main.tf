# Example: KMS key with alias, multi-region replication, and cross-account access

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "kms" {
  source = "./../.."

  aws_region          = "eu-west-1"
  kms_to_create       = [{ name = "rds" }, { name = "s3", kms_alias_prefix = "myorg/" }]
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
  aws_accounts_access = ["111111111111", "222222222222"]
}