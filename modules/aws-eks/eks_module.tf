
module "eks" {

  version = "19.20.0"

  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.cluster_name

  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true

  cluster_endpoint_public_access = true

  cloudwatch_log_group_retention_in_days = 14

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {

    worker = {

      name = var.node_groups[0].name

      instance_type = var.node_groups[0].instance_types[0]

      desired_capacity = var.node_groups[0].desired_capacity

      min_capacity = var.node_groups[0].min_size

      max_capacity = var.node_groups[0].max_size

      labels = var.node_groups[0].k8s_labels

    }
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_alb_node_ports = {
      description = "Allow workers pods to receive communication from ALB"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32400
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.cluster_tags


  cluster_addons = {

    coredns = {

      version              = var.addon_coredns.version

      configuration_values = var.addon_coredns.configuration_values

      resolve_conflicts    = "OVERWRITE"

    }

    kube-proxy = {

      version              = var.addon_kube_proxy.version

      configuration_values = var.addon_kube_proxy.configuration_values

      resolve_conflicts = "OVERWRITE"

    }

    vpc-cni = {

      version              = var.addon_vpc_cni.version

      configuration_values = var.addon_vpc_cni.configuration_values

      resolve_conflicts = "OVERWRITE"

    }

    extra_addons = var.extra_addons

  }

}
