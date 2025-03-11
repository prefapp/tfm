

# Providers: AWS, Kubernetes

provider "aws" {
  region = var.region
}


data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}
