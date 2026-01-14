# --- NLB Listener IPs ---
variable "nlb_listener_ips" {
  description = <<EOT
    Map of port numbers to lists of IP addresses for NLB listeners. If provided for a port, a listener will be created for that port and the specified IPs will be registered as targets. If not provided for a port, no listener will be created for that port.
    Example: { "5671" = ["10.0.1.10", "10.0.2.10"], "15672" = ["10.0.1.11"] }
  EOT
  type        = map(list(string))
  default     = {}
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
}

variable "allowed_ingress_cidrs" {
  description = "CIDR ranges allowed to connect to the AMQPS/HTTPS ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional metadata tags to apply to all resources"
  type        = map(string)
  default     = {}
}
