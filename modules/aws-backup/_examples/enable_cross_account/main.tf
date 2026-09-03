# Example: Minimal AWS Backup vault creation

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

  region                       = "eu-west-1"
  enable_cross_account_backup  = true
}
