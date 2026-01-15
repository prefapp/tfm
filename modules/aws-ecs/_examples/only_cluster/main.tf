# Example: ECS Cluster Only (no services)

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "ecs" {
  source       = "../../"
  cluster_name = "example-autoscaling-cluster"
  #  create_alb      = true
  #  subnet_tag_key  = "Network"
  #  subnet_tag_name = "public"
  vpc_tag_name = "beginners-mq-vpc"
}

output "proba" {
  value = module.ecs
}
