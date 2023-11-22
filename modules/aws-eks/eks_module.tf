
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

  create_cluster_security_group = false

  cluster_security_group_id = "sg-0fe3a16b6ff3056c2"

  iam_role_arn = "arn:aws:iam::041728615317:role/k8s-prefapp-pro-cluster-20220601172007092400000002"

  create_iam_role = false

  enable_irsa = true

  eks_managed_node_groups = var.node_groups

  node_security_group_additional_rules = var.node_security_group_additional_rules

  tags = var.cluster_tags

  cluster_addons =  {

    aws-ebs-csi-driver = {

      addon_version = "v1.16.0-eksbuild.1"

      resolve_conflicts = "OVERWRITE"

      service_account_role_arn = "arn:aws:iam::041728615317:role/AmazonEKS_EBS_CSI_DriverRole"

    }
    coredns = {

      addon_version = "v1.9.3-eksbuild.6"

      resolve_conflicts = "OVERWRITE"

    }

    kube-proxy = {

      addon_version = "v1.25.11-eksbuild.2"

      resolve_conflicts = "OVERWRITE"

    }

    vpc-cni = {

      addon_version = "v1.14.0-eksbuild.3"

      resolve_conflicts = "OVERWRITE"

      configuration_values = jsonencode({
        env = {
          WARM_PREFIX_TARGET       = "1"
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_IP_TARGET           = "4"
        }
      })

    }

  }

  create_kms_key = false

  cluster_encryption_config = {}

  aws_auth_users = var.aws_auth_users

  manage_aws_auth_configmap = true

}
