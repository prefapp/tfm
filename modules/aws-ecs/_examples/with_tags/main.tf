# Example: ECS Service with Autoscaling and Tag-Based VPC/Subnet Discovery

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
  source = "../../"

  cluster_name          = "example-tags-cluster"
  service_name          = "example-tags-service"
  container_definitions = file("${path.module}/container.json")

  security_groups = ["sg-0123456789abcdef0"]

  # VPC discovery
  vpc_tag_key  = "Name"
  vpc_tag_name = "shared-vpc"

  # Subnet discovery
  subnet_tag_key  = "type"
  subnet_tag_name = "private"

  ecs_autoscaling = {
    tags = {
      autoscaling_enabled = false
      min_capacity        = 1
      max_capacity        = 1

      metric_type      = "CPUUtilization"
      metric_statistic = "Average"

      scale = {
        up = {
          threshold           = 70
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods  = 2
          period              = 60
          cooldown            = 60
          adjustment_type     = "ChangeInCapacity"
          scaling_adjustment  = 1
        }
        down = {
          threshold           = 30
          comparison_operator = "LessThanThreshold"
          evaluation_periods  = 2
          period              = 60
          cooldown            = 60
          adjustment_type     = "ChangeInCapacity"
          scaling_adjustment  = -1
        }
      }
    }
  }
}
