module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.2.0"
  name                 = "${var.cluster_name}-vpc"
  cidr                 = var.vpc_config.cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, var.vpc_config.max_azs)
  private_subnets      = var.vpc_config.private_subnets
  public_subnets       = var.vpc_config.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  igw_tags = {
    "concern" = "kubernetes"
  }

  default_vpc_tags = {
    "concern" = "kubernetes"
  }

  tags = {
    "kubernetes.io/cluster/k8s-${var.cluster_tags["project"]}-${var.cluster_tags["env"]}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    "concern"                                   = "kubernetes"
    "type"                                      = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    "concern"                                   = "kubernetes"
    "type"                                      = "private"
  }
}
