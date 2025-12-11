<!-- BEGIN_TF_DOCS -->
### Requirements

No requirements.

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Modules

No modules.

### Resources

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
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the ALB is internal | `bool` | `false` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the Application Load Balancer | `string` | `"ecs-alb-example"` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | IAM assume role policy for the ECS task execution role. Example:<br/>  {<br/>    "Version": "2012-10-17",<br/>    "Statement": [<br/>      {<br/>        "Action": "sts:AssumeRole",<br/>        "Effect": "Allow",<br/>        "Principal": {<br/>          "Service": "ecs-tasks.amazonaws.com"<br/>        }<br/>      }<br/>    ]<br/>  } | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Container definitions in JSON format | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units for the task | `number` | `256` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of desired tasks for the ECS service | `number` | `1` | no |
| <a name="input_ecs_autoscaling"></a> [ecs\_autoscaling](#input\_ecs\_autoscaling) | ECS service autoscaling configuration | <pre>map(object({<br/>    autoscaling_enabled = bool<br/>    min_capacity        = number<br/>    max_capacity        = number<br/><br/>    metric_type      = string<br/>    metric_statistic = string<br/><br/>    custom_metric = optional(object({<br/>      namespace               = string<br/>      name                    = string<br/>      dimensions              = map(string)<br/>      metric_aggregation_type = optional(string)<br/>      treat_missing_data      = optional(string)<br/>      datapoints_to_alarm     = optional(number)<br/>    }))<br/><br/>    scale = object({<br/>      up = object({<br/>        threshold           = number<br/>        comparison_operator = string<br/>        evaluation_periods  = number<br/>        period              = number<br/>        cooldown            = number<br/>        adjustment_type     = string<br/>        scaling_adjustment  = number<br/>      })<br/>      down = object({<br/>        threshold           = number<br/>        comparison_operator = string<br/>        evaluation_periods  = number<br/>        period              = number<br/>        cooldown            = number<br/>        adjustment_type     = string<br/>        scaling_adjustment  = number<br/>      })<br/>      halt = optional(object({}))<br/>      stop = optional(object({}))<br/>    })<br/>  }))</pre> | n/a | yes |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check configuration for the target group | <pre>object({<br/>    path                = string<br/>    protocol            = string<br/>    matcher             = string<br/>    interval            = number<br/>    timeout             = number<br/>    healthy_threshold   = number<br/>    unhealthy_threshold = number<br/>  })</pre> | <pre>{<br/>  "healthy_threshold": 2,<br/>  "interval": 30,<br/>  "matcher": "200",<br/>  "path": "/",<br/>  "protocol": "HTTP",<br/>  "timeout": 5,<br/>  "unhealthy_threshold": 2<br/>}</pre> | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name for the ECS task execution IAM role | `string` | `"ecsTaskExecutionRole"` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type for the ECS service (e.g., EC2 or FARGATE) | `string` | `"FARGATE"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Port for the ALB listener | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | Protocol for the ALB listener | `string` | `"HTTP"` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | List of load balancer configurations for the ECS service. Each object should include target\_group\_arn, container\_name, and container\_port. | <pre>list(object({<br/>    target_group_arn = string<br/>    container_name   = string<br/>    container_port   = number<br/>  }))</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory (MiB) for the task | `number` | `512` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of policy ARNs to attach to the ECS task execution role | `list(string)` | <pre>[<br/>  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"<br/>]</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to associate with the ECS service | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Description of the security group | `string` | `"Allow HTTP inbound traffic"` | no |
| <a name="input_sg_egress"></a> [sg\_egress](#input\_sg\_egress) | List of egress rules for the security group | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_sg_ingress"></a> [sg\_ingress](#input\_sg\_ingress) | List of ingress rules for the security group | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "from_port": 80,<br/>    "protocol": "tcp",<br/>    "to_port": 80<br/>  }<br/>]</pre> | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | `"ecs-service-sg"` | no |
| <a name="input_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#input\_subnet\_cidr\_blocks) | List of CIDR blocks for the public subnets. | `list(string)` | <pre>[<br/>  "172.31.1.0/24",<br/>  "172.31.2.0/24"<br/>]</pre> | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | List of names for the public subnets. | `list(string)` | <pre>[<br/>  "public-subnet-1",<br/>  "public-subnet-2"<br/>]</pre> | no |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Name of the target group | `string` | `"ecs-alb-tg"` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port for the target group | `number` | `80` | no |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol for the target group | `string` | `"HTTP"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where resources will be created | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the ECS cluster |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | ARN of the ECS service |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ARN of the ECS task definition |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets created by the module |
| <a name="output_scale_down_alarm_arns"></a> [scale\_down\_alarm\_arns](#output\_scale\_down\_alarm\_arns) | n/a |
| <a name="output_scale_down_policy_arns"></a> [scale\_down\_policy\_arns](#output\_scale\_down\_policy\_arns) | n/a |
| <a name="output_scale_up_alarm_arns"></a> [scale\_up\_alarm\_arns](#output\_scale\_up\_alarm\_arns) | n/a |
| <a name="output_scale_up_policy_arns"></a> [scale\_up\_policy\_arns](#output\_scale\_up\_policy\_arns) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group used by the ECS service |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group |
<!-- END_TF_DOCS -->