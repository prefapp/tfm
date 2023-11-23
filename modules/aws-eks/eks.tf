################################################################################
# EKS Cluster
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

  manage_aws_auth_configmap = var.manage_aws_auth_configmap

}
