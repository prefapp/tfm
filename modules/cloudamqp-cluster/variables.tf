variable  "cloudamqp_api_key" {
  type        = string
  description = "API key for cloudAMQP"
}

# Instance
variable "cloudamqp_instance_name" {
    description = "Name of the CloudAMQP instance"
    type = string
}

variable "cloudamqp_instance_plan" {
    description = "Plan for the CloudAMQP instance"
    type = string
}

variable "cloudamqp_instance_region" {
    description = "Region for the CloudAMQP instance"
    type = string
}

variable "cloudamqp_instance_nodes" {
    description = "Nodes for the CloudAMQP instance"
    type = number
}

variable "cloudamqp_instance_rqm_version" {
    description = "RabbitMQ version for the CloudAMQP instance"
    type = string
}

variable "cloudamqp_instance_tags" {
    description = "Tags for the CloudAMQP instance"
    type = list(string)
}

# VPC
variable "enable_vpc" {
    description = "Enable VPC creation"
    type = bool
    default = false
}

variable "vpc_name" {
    description = "Name for the CloudAMQP VPC"
    type = string
    default = null
}

variable "vpc_region" {
    description = "Region for the CloudAMQP VPC"
    type = string
    default = null
}

variable "vpc_subnet" {
    description = "Subnet for the CloudAMQP VPC"
    type = list(string)
    default = []
}

variable "vpc_tags" {
    description = "Tags for the CloudAMQP VPC"
    type = list(string)
    default = []
}

# Firewall
variable "enable_firewall" {
    description = "Enable firewall configuration"
    type = bool
    default = false
}

variable "firewall_rules" {
    type = map(object({
        description = string
        ip = string
        ports = list(string)
        services = list(string)
    }))
    default = {}
}

# Notifications
variable "notifications" {
    description = "List of notifications"
    type = list(object({
        type = string
        value = string
        name = string
    }))
    default = []
}

# Alarms
variable "alarms" {
    description = "List of alarms"
    type = list(object({
        type = string
        enabled = bool
        reminder_interval = number
        value_threshold = number
        time_threshold = number
        recipients = list(string)
    }))
    default = []
}

# Metrics integration
variable "enable_metrics" {
    description = "Enable metrics integration"
    type = bool
    default = false
}

variable "metrics_name" {
    description = "Name for metrics integration"
    type = string
    default = null
}

variable "metrics_api_key" {
    description = "API Key for metrics integration"
    type = string
    default = null
}

variable "metrics_region" {
    description = "Region for metrics integration"
    type = string
    default = null
}

variable "metrics_tags" {
    description = "Tags for metrics integration"
    type = list(string)
    default = []
}

# Logs integration
variable "enable_logs" {
    description = "Enable logs integration"
    type = bool
    default = false
}

variable "logs_name" {
    description = "Name of logs integration"
    type = string
    default = null
}

variable "logs_api_key" {
    description = "API  Key for logs integration"
    type = string
    default = null
}

variable "logs_region" {
    description = "Region for logs integration"
    type = list(string)
    default = []
}

variable "logs_tags" {
    description = "Tags for logs integration"
    type = list(string)
    default = []
}
