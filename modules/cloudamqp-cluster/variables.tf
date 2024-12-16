variable "api_key" {
  type        = string
  description = "API key for cloudAMQP"
}

# Instance
variable "instance_name" {
  description = "Name of the CloudAMQP instance"
  type        = string
}

variable "instance_plan" {
  description = "Plan for the CloudAMQP instance"
  type        = string
}

variable "instance_region" {
  description = "Region for the CloudAMQP instance"
  type        = string
}

variable "instance_nodes" {
  description = "Nodes for the CloudAMQP instance"
  type        = number
}

variable "instance_rqm_version" {
  description = "RabbitMQ version for the CloudAMQP instance"
  type        = string
}

variable "instance_tags" {
  description = "Tags for the CloudAMQP instance"
  type        = list(string)
}



# Firewall
variable "enable_firewall" {
  description = "Enable firewall configuration"
  type        = bool
  default     = false
}

variable "firewall_rules" {
  type = map(object({
    description = string
    ip          = string
    ports       = list(string)
    services    = list(string)
  }))
  default = {}
}

# Recipients
variable "recipients" {
  type = map(object({
    value = string
    name  = string
    type  = string
  }))
}

# Alarms
variable "alarms" {
  description = "Map of alarms"
  type = map(object({
    type              = string
    enabled           = bool
    reminder_interval = number
    value_threshold   = number
    time_threshold    = number
    recipient_key     = string

  }))
  default = {}
}


# Metrics integration
variable "metrics_integrations" {
  description = "Map of metrics integrations for CloudAMQP"
  type = map(object({
    name    = string
    api_key = string
    region  = string
    tags    = map(string)
  }))
  default = {}
}

# Logs integration
variable "logs_integrations" {
  type = map(object({
    name               = string
    api_key            = string
    region             = list(string)
    tags               = map(string)
    tenant_id          = string
    application_id     = string
    application_secret = string
    dce_uri            = string
    table              = string
    dcr_id             = string
  }))
  default = {}
}
