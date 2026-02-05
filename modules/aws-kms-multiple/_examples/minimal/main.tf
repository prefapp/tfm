# Example: Minimal KMS key creation

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
  aws_region = "eu-west-1"
  kms_to_create = ["rds", "s3"]
}