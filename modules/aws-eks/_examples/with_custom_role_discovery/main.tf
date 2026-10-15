terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "eks" {
  source = "../.."

  region          = "eu-west-1"
  cluster_name    = "example-custom-integrations"
  cluster_version = "1.33"
  vpc_id          = "vpc-0123456789abcdef0" # Replace with the target VPC ID.

  node_groups                          = {}
  node_security_group_additional_rules = []

  tags = {
    Environment = "example"
    Project     = "custom-integrations"
  }

  # Replace these examples with existing role names and tags in your account.
  # The configured tag map must be non-empty and every tag must match.
  enable_backstage_reader_access_entry = true
  backstage_reader_role_name           = "PlatformBackstageReader"
  backstage_reader_role_tags = {
    ManagedBy   = "PlatformTeam"
    Integration = "backstage-read-only"
  }

  enable_argocd_admin_access_entry = true
  argocd_admin_role_name           = "PlatformArgoCDAdmin"
  argocd_admin_role_tags = {
    ManagedBy   = "PlatformTeam"
    Integration = "argocd-cluster-admin"
  }
}
