provider "aws" {
  region = var.region
}



# data "aws_availability_zones" "available" {}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }



# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster.cluster.token
# }
