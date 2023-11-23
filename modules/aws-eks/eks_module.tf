
module "eks" {

  version = "19.20.0"

  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.cluster_name

  cluster_version = var.cluster_version

  # cluster_endpoint_private_access = true
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  # cluster_endpoint_public_access = true

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  vpc_id = var.vpc_id

  subnet_ids = var.subnet_ids

  create_cluster_security_group = false

  cluster_security_group_id = var.cluster_security_group_id //"sg-0fe3a16b6ff3056c2"

  # iam_role_arn = "arn:aws:iam::041728615317:role/k8s-prefapp-pro-cluster-20220601172007092400000002"
  iam_role_arn = var.cluster_iam_role_arn

  create_iam_role = var.create_cluster_iam_role

  enable_irsa = var.enable_irsa

  eks_managed_node_groups = var.node_groups

  node_security_group_additional_rules = var.node_security_group_additional_rules

  tags = var.cluster_tags

  cluster_addons = var.cluster_addons

  # create_kms_key = false
  create_kms_key = var.create_kms_key

  cluster_encryption_config = var.cluster_encryption_config

  aws_auth_users = var.aws_auth_users

  manage_aws_auth_configmap = var.manage_aws_auth_configmap // true

}
