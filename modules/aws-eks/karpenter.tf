module "karpenter" {
  count = var.enable_karpenter == true ? 1 : 0

  source       = "terraform-aws-modules/eks/aws//modules/karpenter"
  version      = "21.0.0"
  cluster_name = var.cluster_name

  iam_role_name              = format("%s-karpenter-role", var.cluster_name) # Used to generate the instance profile
  create_iam_role            = true
  iam_role_use_name_prefix   = false
  iam_policy_use_name_prefix = true
  create_access_entry        = true
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    Ec2ExtraPolicy               = aws_iam_policy.iam_policy_extra_karpenter[0].arn
  }
  tags = var.tags
}
