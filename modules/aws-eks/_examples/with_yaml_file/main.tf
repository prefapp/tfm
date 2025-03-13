


module "eks_prefapp" {

  source = "../.." # Use the local module

  cluster_name = local.values.cluster_name

  cluster_version = local.values.cluster_version

  node_groups = local.values.node_groups

  region = local.values.region

  create_alb_ingress_iam = local.values.create_alb_ingress_iam

  create_cloudwatch_iam = local.values.create_cloudwatch_iam

  create_efs_driver_iam = local.values.create_efs_driver_iam

  create_external_dns_iam = local.values.create_external_dns_iam

  create_parameter_store_iam = local.values.create_parameter_store_iam

  node_security_group_additional_rules = local.values.node_security_group_additional_rules

  vpc_id = local.values.vpc_id

  subnet_ids = local.values.subnet_ids

  tags = local.values.tags

  cluster_addons = local.values.cluster_addons

  security_groups_ids = local.values.security_groups_ids

  aws_auth_users = local.values.aws_auth_users

  cluster_endpoint_private_access = local.values.cluster_endpoint_private_access

  cluster_endpoint_public_access = local.values.cluster_endpoint_public_access

  cluster_security_group_id = local.values.cluster_security_group_id

  cluster_iam_role_arn = local.values.cluster_iam_role_arn

  cluster_encryption_config = local.values.cluster_encryption_config

  create_cluster_iam_role = local.values.create_cluster_iam_role

  create_kms_key = local.values.create_kms_key

  manage_aws_auth_configmap = local.values.manage_aws_auth_configmap

  enable_irsa = local.values.enable_irsa

}


locals {

  values = yamldecode(file("./values.yaml"))

}


output "summary" {

  value = module.eks_prefapp.summary

}


output "debug" {

  value = module.eks_prefapp.debug

}
