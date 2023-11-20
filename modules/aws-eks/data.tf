data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "cluster_new" {
  name = module.eks.cluster_id
}
