module "karpenter" {
  count = var.enable_karpenter == true ? 1 : 0


  source       = "terraform-aws-modules/eks/aws//modules/karpenter"
  version      = "20.33.1"
  cluster_name = var.cluster_name

  iam_role_name         = format("%s-karpenter-role", var.cluster_name) # Used to generate the instance profile
  create_iam_role       = true
  enable_v1_permissions = true
  enable_irsa           = true

  iam_role_use_name_prefix        = false
  iam_policy_use_name_prefix      = true
  node_iam_role_use_name_prefix   = false
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter-sa"]

  # Since the node group role will already have an access entry
  create_access_entry = true
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ec2extrapolicy             = aws_iam_policy.iam_policy_extra_karpenter[0].arn
  }

  queue_name = format("karpenter-%s", var.cluster_name)
  tags       = var.tags

}