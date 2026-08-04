
/**
 * This file is part of the "Terraform: Up & Running" code base.
 * It is used in the "Deploying an EKS Cluster" chapter.
 */
locals {
  account_id     = try(data.aws_caller_identity.current[0].account_id, "")
  eco_dr_enabled = contains(["true", "1", "on", "yes"], lower(tostring(var.ECO_DR)))
}

moved {
  from = module.eks
  to   = module.eks[0]
}


/*
  This module is used to create the EKS cluster.
  DOC: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
*/

# EKS Cluster Configuration
module "eks" {
  count = local.eco_dr_enabled ? 0 : 1

  version                                = "21.23.0"
  source                                 = "terraform-aws-modules/eks/aws"
  name                                   = var.cluster_name
  kubernetes_version                     = var.cluster_version
  endpoint_private_access                = var.cluster_endpoint_private_access
  endpoint_public_access                 = var.cluster_endpoint_public_access
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  vpc_id                                 = data.aws_vpc.selected[0].id
  subnet_ids                             = local.selected_subnet_ids
  create_security_group                  = var.create_cluster_security_group
  security_group_id                      = var.cluster_security_group_id
  iam_role_arn                           = var.cluster_iam_role_arn
  create_iam_role                        = var.create_cluster_iam_role
  enable_irsa                            = var.enable_irsa
  eks_managed_node_groups                = local.node_groups_with_subnets
  node_security_group_additional_rules   = var.node_security_group_additional_rules
  security_group_additional_rules        = var.cluster_security_group_additional_rules
  tags                                   = var.tags
  cluster_tags                           = merge(var.cluster_tags, var.tags)
  addons                                 = local.cluster_addons
  create_kms_key                         = var.create_kms_key
  encryption_config                      = var.cluster_encryption_config
  access_entries                         = var.access_entries
  fargate_profiles                       = local.fargate_profiles_map
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class
  enabled_log_types                      = var.create_cloudwatch_log_group ? var.enabled_log_types : []
  create_auto_mode_iam_resources         = var.create_auto_mode_iam_resources
}
