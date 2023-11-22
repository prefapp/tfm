provider "aws" {
  region = var.region
}

# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_id
# }


data "aws_eks_cluster_auth" "default" {
  name =  "k8s-prefapp-pro"
}
# data "aws_availability_zones" "available" {}



provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}
