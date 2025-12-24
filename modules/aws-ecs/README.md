<!-- BEGIN_TF_DOCS -->
# **AWS ECS Terraform Module**

## Overview

This Terraform module provisions and manages a complete Amazon ECS (Elastic Container Service) infrastructure for running containerized applications on AWS using Fargate serverless compute. It provides a comprehensive solution for deploying production-ready services without managing underlying infrastructure, handling all necessary networking, load balancing, and scaling configurations.

The module simplifies the complexity of ECS deployments by automating the setup of essential components while maintaining flexibility for customization. It integrates seamlessly with existing AWS infrastructures through support for both direct resource IDs and tag-based discovery, making it suitable for greenfield projects and brownfield integrations alike.

This module provisions an **Amazon ECS service running on Fargate**, including:

- ECS cluster
- Task definition
- ECS service (Fargate launch type)
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

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.scale_down_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.scale_up_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the ALB is internal | `bool` | `false` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the Application Load Balancer | `string` | `"ecs-alb-example"` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | IAM assume role policy for the ECS task execution role. Example:<br/>  {<br/>    "Version": "2012-10-17",<br/>    "Statement": [<br/>      {<br/>        "Action": "sts:AssumeRole",<br/>        "Effect": "Allow",<br/>        "Principal": {<br/>          "Service": "ecs-tasks.amazonaws.com"<br/>        }<br/>      }<br/>    ]<br/>  } | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions in JSON format | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units for the task | `number` | `256` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of desired tasks for the ECS service | `number` | `1` | no |
| <a name="input_ecs_autoscaling"></a> [ecs\_autoscaling](#input\_ecs\_autoscaling) | ECS service autoscaling configuration.<br/><br/>  Special fields:<br/>  - halt: If present, disables all autoscaling resources for this service. The ECS service will use the value of var.desired\_count (the variable's value), not the runtime value that may have been set by autoscaling. Setting halt prevents new autoscaling actions and the service will revert to the value of var.desired\_count. Use this if you want to keep the service running but temporarily suspend autoscaling actions (no scaling up or down will occur).<br/>  - stop: If present, sets desired\_count to 0, stopping all running tasks for the service. Use this if you want to fully stop the ECS service (no tasks running), regardless of autoscaling settings. Autoscaling resources will also be disabled.<br/><br/>  Use halt to pause scaling but keep the service alive; use stop to fully stop the service and all its tasks. | <pre>map(object({<br/>    autoscaling_enabled = bool<br/>    min_capacity        = number<br/>    max_capacity        = number<br/><br/>    metric_type      = string<br/>    metric_statistic = string<br/><br/>    custom_metric = optional(object({<br/>      namespace               = string<br/>      name                    = string<br/>      dimensions              = map(string)<br/>      metric_aggregation_type = optional(string)<br/>      treat_missing_data      = optional(string)<br/>      datapoints_to_alarm     = optional(number)<br/>    }))<br/><br/>    scale = object({<br/>      up = object({<br/>        threshold           = number<br/>        comparison_operator = string<br/>        evaluation_periods  = number<br/>        period              = number<br/>        cooldown            = number<br/>        adjustment_type     = string<br/>        scaling_adjustment  = number<br/>      })<br/>      down = object({<br/>        threshold           = number<br/>        comparison_operator = string<br/>        evaluation_periods  = number<br/>        period              = number<br/>        cooldown            = number<br/>        adjustment_type     = string<br/>        scaling_adjustment  = number<br/>      })<br/>      halt = optional(object({}))<br/>      stop = optional(object({}))<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check configuration for the target group | <pre>object({<br/>    path                = string<br/>    protocol            = string<br/>    matcher             = string<br/>    interval            = number<br/>    timeout             = number<br/>    healthy_threshold   = number<br/>    unhealthy_threshold = number<br/>  })</pre> | <pre>{<br/>  "healthy_threshold": 2,<br/>  "interval": 30,<br/>  "matcher": "200",<br/>  "path": "/",<br/>  "protocol": "HTTP",<br/>  "timeout": 5,<br/>  "unhealthy_threshold": 2<br/>}</pre> | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name for the ECS task execution IAM role | `string` | `"ecsTaskExecutionRole"` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type for the ECS service (e.g., EC2 or FARGATE) | `string` | `"FARGATE"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Port for the ALB listener | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | Protocol for the ALB listener | `string` | `"HTTP"` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | List of load balancer configurations for the ECS service. Each object should include:<br/>- target\_group\_arn (optional): ARN of the target group. If not provided or empty, the module will use the ARN of the target group it creates internally.<br/>- container\_name: Name of the container to associate with the load balancer.<br/>- container\_port: Port on the container to associate with the load balancer. | <pre>list(object({<br/>    target_group_arn = optional(string)<br/>    container_name   = string<br/>    container_port   = number<br/>  }))</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory (MiB) for the task | `number` | `512` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of policy ARNs to attach to the ECS task execution role | `list(string)` | <pre>[<br/>  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"<br/>]</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to associate with the ECS service | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Description of the security group | `string` | `"Allow HTTP inbound traffic"` | no |
| <a name="input_sg_egress"></a> [sg\_egress](#input\_sg\_egress) | List of egress rules for the security group | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_sg_ingress"></a> [sg\_ingress](#input\_sg\_ingress) | List of ingress rules for the security group | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "from_port": 80,<br/>    "protocol": "tcp",<br/>    "to_port": 80<br/>  }<br/>]</pre> | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | `"ecs-service-sg"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to use for the ECS service and ALB. If not set, the module will try to locate subnets using subnet\_tag\_key and subnet\_tag\_name (e.g., tag:Name). | `list(string)` | `null` | no |
| <a name="input_subnet_tag_key"></a> [subnet\_tag\_key](#input\_subnet\_tag\_key) | Tag key used to search the subnets when subnet\_ids is not provided | `string` | `"type"` | no |
| <a name="input_subnet_tag_name"></a> [subnet\_tag\_name](#input\_subnet\_tag\_name) | Tag name of the subnets to look up | `string` | `""` | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Name of the target group | `string` | `"ecs-alb-tg"` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port for the target group | `number` | `80` | no |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol for the target group | `string` | `"HTTP"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where resources will be created. If not set, the module will look up the VPC using vpc\_tag\_key and vpc\_tag\_name. | `string` | `null` | no |
| <a name="input_vpc_tag_key"></a> [vpc\_tag\_key](#input\_vpc\_tag\_key) | Tag key used to search the VPC when vpc\_id is not provided. Default is 'Name'. | `string` | `"Name"` | no |
| <a name="input_vpc_tag_name"></a> [vpc\_tag\_name](#input\_vpc\_tag\_name) | Tag value of the VPC to look up (e.g., value for tag 'Name' = 'my-vpc') | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the ECS cluster |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | ARN of the ECS service |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ARN of the ECS task definition |
| <a name="output_scale_down_alarm_arns"></a> [scale\_down\_alarm\_arns](#output\_scale\_down\_alarm\_arns) | ARNs of the scale down CloudWatch alarms for each ECS service. |
| <a name="output_scale_down_policy_arns"></a> [scale\_down\_policy\_arns](#output\_scale\_down\_policy\_arns) | ARNs of the scale down policies for each ECS service. |
| <a name="output_scale_up_alarm_arns"></a> [scale\_up\_alarm\_arns](#output\_scale\_up\_alarm\_arns) | ARNs of the scale up CloudWatch alarms for each ECS service. |
| <a name="output_scale_up_policy_arns"></a> [scale\_up\_policy\_arns](#output\_scale\_up\_policy\_arns) | ARNs of the scale up policies for each ECS service. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group used by the ECS service |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-ecs/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-ecs/_examples/basic) - Basic ECS Service with ALB + Fargate
- [Autoscaling enabled](https://github.com/prefapp/tfm/tree/main/modules/aws-ecs/_examples/autoscaling) - ECS Service with CPU-Based Autoscaling
- [With tags](https://github.com/prefapp/tfm/tree/main/modules/aws-ecs/_examples/with\_tags) - ECS Service with Autoscaling and Tag-Based VPC/Subnet Discovery

## Remote resources
- Terraform: https://www.terraform.io/
- Amazon ECS: [https://aws.amazon.com/ecs/](https://aws.amazon.com/ecs/)
- Terraform AWS Provider: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)
- Application Auto Scaling: [https://docs.aws.amazon.com/autoscaling/application/](https://docs.aws.amazon.com/autoscaling/application/)
- Elastic Load Balancing (ALB): [https://docs.aws.amazon.com/elasticloadbalancing/latest/application/](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
