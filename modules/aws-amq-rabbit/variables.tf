# --- NLB TLS Policy ---
variable "lb_ssl_policy" {
  description = "TLS policy for the NLB listener. Default is 'ELBSecurityPolicy-TLS-1-2-2017-01' for compatibility with TLS 1.2 and 1.3. See AWS documentation for available policies."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}
# --- NLB Listener IPs ---
variable "nlb_listener_ips" {
  description = <<EOT
    List of objects to define NLB listeners and targets. Each object can specify:
      - ips: List of broker IPs to register as targets
      - target_port: Port number or name (e.g., 5671, 15672, "AMQPS", "Management UI")
      - listener_port: (Optional) Port number for the NLB listener. If not set, uses target_port.
    Example:
      [
        {
          ips = ["10.0.1.10", "10.0.2.10"]
          target_port = 5671
          listener_port = 8081
        },
        {
          ips = ["10.0.1.11"]
          target_port = "Management UI"
          listener_port = 8080
        }
      ]
  EOT
  type = list(object({
    ips              = list(string)
    target_port      = optional(any) # number or string (name)
    listener_port    = optional(number)
    expose_all_ports = optional(bool)
  }))
  default = []
}
# --- Port Exposure ---
variable "exposed_ports" {
  description = "List of ports to expose for RabbitMQ broker (AMQPS, management, etc.). Default is [5671]."
  type        = list(number)
  default     = [5671]
  validation {
    condition     = length(var.exposed_ports) > 0 && alltrue([for p in var.exposed_ports : p >= 1 && p <= 65535])
    error_message = "You must specify at least one port in exposed_ports, and all ports must be in the range 1-65535."
  }
}
variable "existing_security_group_id" {
  description = "ID of an existing Security Group to use. If not set, a new one will be created."
  type        = string
  default     = null
}

variable "access_mode" {
  description = "Access mode for the broker: 'public', 'private', or 'private_with_nlb'."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "private_with_nlb"], var.access_mode)
    error_message = "access_mode must be one of: public, private, private_with_nlb."
  }
}

# --- Project Metadata ---
variable "project_name" {
  description = "Generic project identifier used for resource naming (e.g., 'messaging-hub')"
  type        = string
}

variable "environment" {
  description = "Target environment for the deployment (e.g., 'prod', 'staging')"
  type        = string
}

# --- Credentials ---
variable "mq_username" {
  description = "Administrative username for the RabbitMQ broker"
  type        = string
  sensitive   = true
}

# --- Network Discovery ---
variable "vpc_id" {
  description = "ID of the target VPC. Takes precedence over 'vpc_name'."
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Value of the 'Name' tag for VPC lookup if 'vpc_id' is null."
  type        = string
  default     = null
}

variable "broker_subnet_ids" {
  description = "List of private subnet IDs for the Broker. Takes precedence over filters."
  type        = list(string)
  default     = []
}

variable "broker_subnet_filter_tags" {
  description = "Tags used to discover subnets for the Broker (e.g., { 'NetworkTier' = 'Private' })."
  type        = map(string)
  default     = {}
}

variable "lb_subnet_ids" {
  description = "List of subnet IDs for the NLB. Takes precedence over filters."
  type        = list(string)
  default     = []
}

variable "lb_subnet_filter_tags" {
  description = "Tags used to discover subnets for the NLB (e.g., { 'NetworkTier' = 'Public' })."
  type        = map(string)
  default     = {}
}

# --- Broker Specs ---
variable "host_instance_type" {
  description = "Instance class for the broker (e.g., mq.t3.micro)"
  type        = string
  default     = "mq.t3.micro"
}

variable "engine_version" {
  description = "Version of the RabbitMQ engine"
  type        = string
  default     = "3.13"
}

variable "deployment_mode" {
  description = "Broker deployment strategy: SINGLE_INSTANCE or CLUSTER_MULTI_AZ"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "enable_cloudwatch_logs" {
  description = "Toggle for CloudWatch logging"
  type        = bool
  default     = true
}

# --- Load Balancer & Security ---
variable "lb_certificate_arn" {
  description = "ARN of the ACM certificate for the TLS listener. Required only if access_mode is 'private_with_nlb'."
  type        = string
  default     = null

  validation {
    condition     = var.access_mode != "private_with_nlb" || (var.access_mode == "private_with_nlb" && var.lb_certificate_arn != null && var.lb_certificate_arn != "")
    error_message = "You must provide a non-empty lb_certificate_arn when access_mode is 'private_with_nlb'."
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDR ranges allowed to connect to all exposed ports (e.g., AMQPS, AMQP, STOMP, MQTT, Management UI, etc.)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional metadata tags to apply to all resources"
  type        = map(string)
  default     = {}
}
