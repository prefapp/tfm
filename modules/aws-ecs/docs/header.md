# **AWS ECS Terraform Module**

## Overview

This Terraform module provisions and manages a complete Amazon ECS(Elastic Container Service) infrastructure for running containerized applications on AWS. It provides a comprehensive solution for deploying production-ready services using either Fargate serverless compute or EC2 instances, handling all necessary networking, load balancing, and scaling configurations.

The module simplifies the complexity of ECS deployments by automating the setup of essential components while maintaining flexibility for customization. It integrates seamlessly with existing AWS infrastructures through support for both direct resource IDs and tag-based discovery, making it suitable for greenfield projects and brownfield integrations alike.

This module provisions an **Amazon ECS service running on Fargate or EC2**, including:

- ECS cluster
- Task definition
- ECS service
- Application Load Balancer (ALB)
- Target group and listener
- Autoscaling policies (optional)
- IAM execution role
- Security group
- VPC and subnet discovery by ID or tags

It is designed to be flexible, production‑ready, and easy to integrate into existing infrastructures.

## Key Features

- **ECS Cluster & Service**: Creates a fully managed ECS cluster and service with configurable launch type.
- **Task Definition**: Supports custom container definitions, CPU/memory sizing, and IAM execution roles.
- **Autoscaling**: Built‑in support for CloudWatch alarms and App Auto Scaling policies, including `halt` and `stop` modes.
- **Load Balancing**: Optional ALB with listener, target group, health checks, and container port mapping.
- **Flexible Networking**: VPC and subnet selection via IDs or tag discovery.
- **Security Group Management**: Customizable ingress/egress rules.

## Basic Usage

### Minimal Example (Fargate)


```hcl
module "ecs" {
  source = "github.com/prefapp/tfm/modules/ecs"

  cluster_name           = "demo-cluster"
  service_name           = "demo-service"
  container_definitions  = file("container.json")
  security_groups        = ["sg-1234567890abcdef0"]

  ecs_autoscaling = {
    demo = {
      autoscaling_enabled = false
      min_capacity        = 1
      max_capacity        = 1
      metric_type         = "CPUUtilization"
      metric_statistic    = "Average"

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
```



### Using VPC and Subnet Tag Discovery

```hcl
module "ecs" {
  source = "github.com/prefapp/tfm/modules/ecs"

  cluster_name          = "demo"
  service_name          = "demo-service"
  container_definitions = file("container.json")
  security_groups       = ["sg-1234567890abcdef0"]

  vpc_tag_name = "shared-vpc"
  subnet_tag_key  = "type"
  subnet_tag_name = "private"
}
```



## File Structure

The module is organized with the following directory and file structure:

```
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── data.tf
├── autoscaling.tf
├── alb.tf
├── ecs.tf
├── iam.tf
├── security_group.tf
├── _examples
│   ├── basic
│   ├── autoscaling
│   └── with_tags
├── README.md
└── docs
└── header.md
```

- **`main.tf`**: Entry point that wires together all module components.
- **`ecs.tf`**: ECS cluster, task definition, and service configuration.
- **`alb.tf`**: Application Load Balancer, listener, and target group.
- **`autoscaling.tf`**: CloudWatch alarms and scaling policies.
- **`iam.tf`**: IAM role and policy attachments for ECS task execution.
- **`security_group.tf`**: Security group creation and rules.
- **`data.tf`**: VPC and subnet discovery using IDs or tags.
- **`_examples/`**: Example configurations demonstrating different use cases.

