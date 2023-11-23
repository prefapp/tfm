
################################################################################
# Required providers
################################################################################
terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }

  }

}


################################################################################
# SUBMODULES CONFIGURATION
################################################################################



################################################################################
# Application Load Balancer (ALB)
################################################################################
module "alb" {

  source = "./modules/alb"

  create_alb_ingress_iam = var.alb_ingress_enabled

}
