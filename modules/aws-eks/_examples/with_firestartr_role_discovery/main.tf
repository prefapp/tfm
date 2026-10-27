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
  cluster_name    = "example-firestartr-integrations"
  cluster_version = "1.33"
  vpc_id          = "vpc-0123456789abcdef0" # Replace with the target VPC ID.

  # Replace with subnets in the target VPC spanning at least two availability zones.
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  node_groups                          = {}
  node_security_group_additional_rules = {}

  tags = {
    Environment = "example"
    Project     = "firestartr-integration"
  }

  # These role names and tags are the module defaults for Firestartr.
  enable_backstage_reader_access_entry = true
  backstage_reader_role_name           = "FirestartrBackstageReader"
  backstage_reader_role_tags = {
    FirestartrIntegration = "backstage-reader"
    ManagedBy             = "Prefapp"
    ProvisionedBy         = "CloudFormation"
  }

  enable_argocd_admin_access_entry = true
  argocd_admin_role_name           = "FirestartrArgoCDAdmin"
  argocd_admin_role_tags = {
    FirestartrIntegration = "argocd-admin"
    ManagedBy             = "Prefapp"
    ProvisionedBy         = "CloudFormation"
  }
}
