
module "eks" {

  version = "19.20.0"

  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.cluster_name

  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true

  cluster_endpoint_public_access = true

  cloudwatch_log_group_retention_in_days = 14

  vpc_id = var.vpc_id

  subnet_ids = var.subnet_ids

  enable_irsa = true

  eks_managed_node_groups = var.node_groups

  node_security_group_additional_rules = var.node_security_group_additional_rules

  tags = var.cluster_tags

  cluster_addons = var.addons


  # coredns = {

  #   version = var.addon_coredns.version

  #   configuration_values = var.addon_coredns.configuration_values

  #   resolve_conflicts = "OVERWRITE"

  # }

  # kube-proxy = {

  #   version = var.addon_kube_proxy.version

  #   configuration_values = var.addon_kube_proxy.configuration_values

  #   resolve_conflicts = "OVERWRITE"

  # }

  # vpc-cni = {

  #   version = var.addon_vpc_cni.version

  #   configuration_values = var.addon_vpc_cni.configuration_values

  #   resolve_conflicts = "OVERWRITE"

  # }

  # extra_addons = var.extra_addons

  # }

  # fargate_profiles = {
  #   default = {
  #     name = "default"
  #     selectors = [
  #       {
  #         namespace = var.fargate_profiles.namespace
  #         labels = var.fargate_profiles.labels
  #       }
  #     ]
  #   }
  # }

}
