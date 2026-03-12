# Example: Basic ECS Service with ALB + Fargate

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

  cluster_name          = "example-basic-cluster"
  service_name          = "example-basic-service"
  container_definitions = file("${path.module}/container.json")

  security_groups = ["sg-0123456789abcdef0"]

  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-11111111", "subnet-22222222"]

  ecs_autoscaling = {
    basic = {
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
