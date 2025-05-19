
/**
 * This file is part of the "Terraform: Up & Running" code base.
 * It is used in the "Deploying an EKS Cluster" chapter.
 */
locals {
  account_id = data.aws_caller_identity.current.account_id
}


/*
  This module is used to create the EKS cluster.
  DOC: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
*/

# EKS Cluster Configuration
module "eks" {
  version                                = "20.33.1"
  source                                 = "terraform-aws-modules/eks/aws"
  cluster_name                           = var.cluster_name
  cluster_version                        = var.cluster_version
  cluster_endpoint_private_access        = var.cluster_endpoint_private_access
  cluster_endpoint_public_access         = var.cluster_endpoint_public_access
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  vpc_id                                 = data.aws_vpc.selected.id
  subnet_ids                             = local.private_subnet_ids
  create_cluster_security_group          = var.create_cluster_security_group
  cluster_security_group_id              = var.cluster_security_group_id
  iam_role_arn                           = var.cluster_iam_role_arn
  create_iam_role                        = var.create_cluster_iam_role
  enable_irsa                            = var.enable_irsa
  eks_managed_node_groups                = var.node_groups
  node_security_group_additional_rules   = var.node_security_group_additional_rules
  tags                                   = var.tags
  cluster_tags                           = merge(var.cluster_tags, var.tags)
  cluster_addons                         = local.cluster_addons
  create_kms_key                         = var.create_kms_key
  cluster_encryption_config              = var.cluster_encryption_config
  access_entries                         = var.access_entries
  fargate_profiles                       = var.fargate_profiles
}
