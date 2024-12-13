variable  "api_key" {
  type = string
  description = "API key for cloudAMQP"
}

# Instance
variable "instance_name" {
    description = "Name of the CloudAMQP instance"
    type = string
}

variable "instance_plan" {
    description = "Plan for the CloudAMQP instance"
    type = string
}

variable "instance_region" {
    description = "Region for the CloudAMQP instance"
    type = string
}

variable "instance_nodes" {
    description = "Nodes for the CloudAMQP instance"
    type = number
}

variable "instance_rqm_version" {
    description = "RabbitMQ version for the CloudAMQP instance"
    type = string
}

variable "instance_tags" {
    description = "Tags for the CloudAMQP instance"
    type = list(string)
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

# Recipients
variable "recipients" {
    type = map(object({
        value = string
        name = string
        type = string
    }))
}

# Alarms
variable "alarms" {
  description = "Map of alarms"
  type = map(object({
    type = string
    enabled = bool
    reminder_interval = number
    value_threshold = number
    time_threshold = number
    recipient_key = string

  }))
    default = {}
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
    type = map(string)
    default = {}
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

variable "tenant_id" {
    description = "Tenant ID for the logs integration"
    type = string
    default = null
}

variable "application_id" {
    description = "Application ID for the logs integration"
    type = string
    default = null
}

variable "application_secret" {
    description = "Aplication secret for the logs integration"
    type = string
    default = null
}

variable "dce_uri" {
    description = "URI for the logs integration"
    type = string
    default = null
}

variable "table" {
    description = "Table name for the logs integration (needs to end with _CL)"
    type = string
    default = null
}

variable "dcr_id" {
    description = "DCR ID for the logs integration"
    type = string
    default = null
}
