# Example: ECS Service with CPU-Based Autoscaling

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

module "service" {
  source = "../../"

  cluster_name          = "example-autoscaling-cluster"
  create_cluster           = false
  service_name          = "example-autoscaling-api-service"
  container_definitions = file("${path.module}/container.json")

  security_groups = ["sg-0123456789abcdef0"]

  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-11111111", "subnet-22222222"]

  name_existing_alb = "ecs-alb-example"
  static_content_path_pattern = "/api/*"
  create_alb = false

  ecs_autoscaling = {
    autoscaling = {
      autoscaling_enabled = true
      min_capacity        = 1
      max_capacity        = 5

      metric_type      = "CPUUtilization"
      metric_statistic = "Average"

      scale = {
        up = {
          threshold           = 75
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods  = 2
          period              = 60
          cooldown            = 60
          adjustment_type     = "ChangeInCapacity"
          scaling_adjustment  = 1
        }
        down = {
          threshold           = 40
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
