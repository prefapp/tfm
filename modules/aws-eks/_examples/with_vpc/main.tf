# Example: modules eks with vpc

terraform {
  required_version = ">= 1.10"
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
  source = "../../"

  cluster_name    = "cluster-name"
  cluster_version = "1.33"

  vpc_id = "vpc-0db780b1574aa1010"

  node_groups = {
    worker = {
      name                       = "worker"
      instance_types             = ["t3.medium"]
      desired_size               = 1
      min_size                   = 0
      max_size                   = 3
      create_iam_role            = true
      launch_template_version    = "1"
      use_custom_launch_template = true
      create                     = true
      create_launch_template     = true
      labels = {
        GithubRepo  = "infra"
        GithubOrg   = "ORGNAME"
        Environment = "dev-worker"
      }
      pre_bootstrap_user_data = <<-EOF
        #!/bin/bash
        set -ex
        cat <<-EOT > /etc/profile.d/bootstrap.sh
        export CONTAINER_RUNTIME="containerd"
        export USE_MAX_PODS=false
        export KUBELET_EXTRA_ARGS="--max-pods=110"
        EOT
        # Source extra environment variables in bootstrap script
        sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
      EOF
    }
  }


  region = "eu-west-1"

  node_security_group_additional_rules = []


  tags = {
    Environment = "dev"
    Project     = "my-project"
  }

  # Optional Backstage / ArgoCD access. Defaults discover Firestartr roles
  # with their FirestartrIntegration, ManagedBy, and ProvisionedBy tags.
  # Override the names and non-empty tag maps for another integration setup.
  enable_backstage_reader_access_entry = false
  backstage_reader_role_name           = "PlatformBackstageReader"
  backstage_reader_role_tags = {
    Integration = "backstage-reader"
    ManagedBy   = "PlatformTeam"
  }

  enable_argocd_admin_access_entry = false
  argocd_admin_role_name           = "PlatformArgoCDAdmin"
  argocd_admin_role_tags = {
    Integration = "argocd-admin"
    ManagedBy   = "PlatformTeam"
  }

}
