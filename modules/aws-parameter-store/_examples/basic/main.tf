# Example: Basic CloudFront Distribution with S3 Origin

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "cloudfront-delivery" {
  source = "../../"

  cluster_name = "common-env"
  env          = "dev"
  region       = "eu-west-1"
  aws_account  = "012456789"
  parameters   = {}
  services = {
    github = {
      name = "github"
    }
  }
}