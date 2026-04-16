# Example: Basic Parameter Store access from EKS

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.40"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "parameter-store" {
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
