## VPC
variable "vpc_id" {
  description = "ID of the VPC where resources will be created. If not set, the module will look up the VPC using vpc_tag_key and vpc_tag_name."
}

variable "vpc_tag_key" {
  description = "Tag key used to search the VPC when vpc_id is not provided. Default is 'Name'."
  type        = string
  default     = "Name"
}

variable "vpc_tag_name" {
  description = "Tag value of the VPC to look up (e.g., value for tag 'Name' = 'my-vpc')"
  type        = string
  default     = ""
  validation {
    condition     = var.vpc_id != null || var.vpc_tag_name != ""
    error_message = "You must specify either vpc_id or vpc_tag_name."
  }
}


variable "subnet_tag_key" {
  description = "Tag key used to search the subnets when subnet_ids is not provided"
  type        = string
  default     = "type"
}

variable "subnet_tag_name" {
  description = "Tag name of the subnets to look up"
  type        = string
  default     = ""
  validation {
    condition     = var.subnet_ids != null || var.subnet_tag_name != ""
    error_message = "You must specify either subnet_ids or subnet_tag_name."
  }
}

variable "subnet_ids" {
  description = <<EOT
List of subnet IDs to use for the ECS service and ALB. If not set, the module will try to locate subnets using subnet_tag_key and subnet_tag_name (e.g., tag:Name).
EOT
  type        = list(string)
  default     = null
}

# VPC and Subnet filters

## ECS Cluster
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}


## ECS Cluster Task Definition
variable "container_definitions" {
  description = "Container definitions in JSON format"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (MiB) for the task"
  type        = number
  default     = 512
}


## ECS Service
variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "desired_count" {
  description = "Number of desired tasks for the ECS service"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type for the ECS service (e.g., EC2 or FARGATE)"
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["EC2", "FARGATE"], var.launch_type)
    error_message = "launch_type must be either 'EC2' or 'FARGATE'."
  }
}


variable "security_groups" {
  description = "List of security group IDs to associate with the ECS service"
  type        = list(string)
}

variable "load_balancer" {
  description = <<EOT
List of load balancer configurations for the ECS service. Each object should include:
- target_group_arn (optional): ARN of the target group. If not provided or empty, the module will use the ARN of the target group it creates internally.
- container_name: Name of the container to associate with the load balancer.
- container_port: Port on the container to associate with the load balancer.
EOT
  type = list(object({
    target_group_arn = optional(string)
    container_name   = string
    container_port   = number
  }))
  default = []
  validation {
      condition     = length(var.load_balancer) > 0
      error_message = "You must provide at least one load_balancer object with container_name and container_port for the ECS service."
  }
}


### IAM Roles
variable "iam_role_name" {
  description = "Name for the ECS task execution IAM role"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "assume_role_policy" {
  description = <<EOT
  IAM assume role policy for the ECS task execution role. Example:
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        }
      }
    ]
  }
  EOT
  type        = string
  default     = ""
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the ECS task execution role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}





### ALB
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "ecs-alb-example"
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}



variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = "ecs-alb-tg"
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
  validation {
      condition     = var.target_group_protocol != ""
      error_message = "target_group_protocol must not be empty."
  }
}


variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
  default     = "HTTP"
}

variable "health_check" {
  description = "Health check configuration for the target group"
  type = object({
    path                = string
    protocol            = string
    matcher             = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
  default = {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


### Security group
variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "ecs-service-sg"
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
  default     = "Allow HTTP inbound traffic"
}

variable "sg_ingress" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "sg_egress" {
  description = "List of egress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}



### ECS Autoscaling
variable "ecs_autoscaling" {
  description = <<EOT
  ECS service autoscaling configuration.

  Special fields:
  - halt: If present, disables all autoscaling resources for this service. The ECS service will continue running with whatever desired_count was previously set (which could have been modified by autoscaling). Setting halt prevents new autoscaling actions but does not change or enforce the current desired_count value. Use this if you want to keep the service running but temporarily suspend autoscaling actions (no scaling up or down will occur).
  - stop: If present, sets desired_count to 0, stopping all running tasks for the service. Use this if you want to fully stop the ECS service (no tasks running), regardless of autoscaling settings. Autoscaling resources will also be disabled.

  Use halt to pause scaling but keep the service alive; use stop to fully stop the service and all its tasks.
EOT
  type = map(object({
    autoscaling_enabled = bool
    min_capacity        = number
    max_capacity        = number

    metric_type      = string
    metric_statistic = string

    custom_metric = optional(object({
      namespace               = string
      name                    = string
      dimensions              = map(string)
      metric_aggregation_type = optional(string)
      treat_missing_data      = optional(string)
      datapoints_to_alarm     = optional(number)
    }))

    scale = object({
      up = object({
        threshold           = number
        comparison_operator = string
        evaluation_periods  = number
        period              = number
        cooldown            = number
        adjustment_type     = string
        scaling_adjustment  = number
      })
      down = object({
        threshold           = number
        comparison_operator = string
        evaluation_periods  = number
        period              = number
        cooldown            = number
        adjustment_type     = string
        scaling_adjustment  = number
      })
      halt = optional(object({}))
      stop = optional(object({}))
    })
  }))
}
