# Example: AWS OIDC authentication for specific Git tags

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
  subs = [
    "repo:ORG-B/repo-z:ref:refs/tags/rc-*",
    "repo:ORG-A/repo-A:ref:refs/tags/rc-*",
  ]
}