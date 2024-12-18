variable "api_key" {
  type        = string
  description = "API key for cloudAMQP"
}

# Instance
variable "cloudamqp_instance" {
  description = "Map of CloudAMQP instance configurations"
  type = object({
    name        = string
    plan        = string
    region      = string
    tags        = optional(list(string), [])
    nodes       = number
    rmq_version = string
  })
  default = {
    name        = "default_instance"
    plan        = "lemming"
    region      = "azure-arm::westeurope"
    tags        = ["default", "development"]
    nodes       = 1
    rmq_version = "4.0.4"
  }
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
