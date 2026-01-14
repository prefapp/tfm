# Example: OIDC authentication configuration for a specific Git branch

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "oidc" {
  source = "../../"
  organization = "1111111111111"
  subs = [
    "repo:ORG-B/repo-a:ref:refs/heads/dev",
  ]
}