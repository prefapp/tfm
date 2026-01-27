# Example: ECS Service with Autoscaling and Tag-Based VPC/Subnet Discovery

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
  alias               = "rds"
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
  aws_accounts_access = ["111111111111","222222222222"]
}