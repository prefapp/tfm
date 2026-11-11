# Keep existing managed addons in state when the upstream EKS module switches
# their resource address to the before_compute resource.
moved {
  from = module.eks.aws_eks_addon.this["vpc-cni"]
  to   = module.eks.aws_eks_addon.before_compute["vpc-cni"]
}

moved {
  from = module.eks.aws_eks_addon.this["eks-pod-identity-agent"]
  to   = module.eks.aws_eks_addon.before_compute["eks-pod-identity-agent"]
}
