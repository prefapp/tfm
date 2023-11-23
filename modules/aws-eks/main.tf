
################################################################################
# Required providers
################################################################################
terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }

  }

}

################################################################################
# Local Variables
################################################################################
locals {

  account_id = data.aws_caller_identity.current.account_id

}

################################################################################
# EKS Cluster Configuration
################################################################################

module "eks" {

  version = "19.20.0"

  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.cluster_name

  cluster_version = var.cluster_version

  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  vpc_id = var.vpc_id

  subnet_ids = var.subnet_ids

  create_cluster_security_group = false

  cluster_security_group_id = var.cluster_security_group_id

  iam_role_arn = var.cluster_iam_role_arn

  create_iam_role = var.create_cluster_iam_role

  enable_irsa = var.enable_irsa

  eks_managed_node_groups = var.node_groups

  node_security_group_additional_rules = var.node_security_group_additional_rules

  tags = var.cluster_tags

  cluster_addons = var.cluster_addons

  create_kms_key = var.create_kms_key

  cluster_encryption_config = var.cluster_encryption_config

  aws_auth_users = var.aws_auth_users

  aws_auth_roles = var.aws_auth_roles

  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  fargate_profiles = var.fargate_profiles

}


################################################################################
# SUBMODULES CONFIGURATION
################################################################################

################################################################################
# Application Load Balancer (ALB)
################################################################################
module "alb" {

  source = "./modules/alb"

  create_alb_ingress_iam = var.alb_ingress_enabled

  oidc_provider_arn =  module.eks.oidc_provider_arn

  cluster_tags = var.cluster_tags
}

################################################################################
# Cloudwatch Logs
################################################################################

module "cloudwatch" {

  source = "./modules/cloudwatch"

  create_cloudwatch_iam = var.cloudwatch_enabled

  oidc_provider_arn = module.eks.oidc_provider_arn

}

################################################################################
# EFS CSI Driver (Elasic File System Container Storage Interface Driver)
################################################################################

module "efs_csi_driver" {

  source = "./modules/efs_csi_driver"

  create_efs_driver_iam = var.efs_driver_enabled

  oidc_provider_arn = module.eks.oidc_provider_arn

}

################################################################################
# External DNS
################################################################################

module "external_dns" {

  source = "./modules/external_dns"

  create_external_dns_iam = var.external_dns_enabled

  oidc_provider_arn = module.eks.oidc_provider_arn

}

################################################################################
# AWS Paramter Store
################################################################################

module "parameter_store" {

  source = "./modules/parameter_store"

  create_parameter_store_iam = var.parameter_store_enabled

  oidc_provider_arn = module.eks.oidc_provider_arn

  region = var.region

  account_id = local.account_id

}
