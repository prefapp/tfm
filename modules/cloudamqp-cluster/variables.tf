# Instance
variable "cloudamqp_instance" {
  description = "Map of CloudAMQP instance configurations"
  type = object({
    name                = string
    plan                = string
    region              = string
    tags                = optional(list(string), [])
    nodes               = number
    rmq_version         = string
    vpc_id              = string
    no_default_alarms   = optional(bool)
    keep_associated_vpc = optional(bool)
  })
   default = {
     name        = "default_instance"
     plan        = "lemming"
     region      = "azure-arm::westeurope"
     tags        = []
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
    description = optional(string)
    ip          = string
    ports       = optional(list(string))
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
  default = {}
}


# Alarms
variable "alarms" {
  description = "Map of alarms"
  type = map(object({
    type              = string
    enabled           = bool
    reminder_interval = optional(number)
    value_threshold   = optional(number)
    time_threshold    = optional(number)
    recipient_key     = optional(list(string))
    message_type      = optional(string)
    queue_regex       = optional(string)
    vhost_regex       = optional(string)

  }))
  default = {}
}


# Metrics integration
variable "metrics_integrations" {
  description = "Map of metrics integrations for CloudAMQP"
  type = map(object({
    name              = string
    region            = optional(string)
    access_key_id     = optional(string)
    secret_access_key = optional(string)
    iam_role          = optional(string)
    iam_external_id   = optional(string)
    api_key           = optional(string)
    email             = optional(string)
    client_email      = optional(string)
    project_id        = optional(string)
    private_key       = optional(string)
    tags              = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "cloudwatch" || (
          lookup(val, "region", "") != "" &&
          lookup(val, "access_key_id", "") != "" &&
          lookup(val, "secret_access_key", "") != ""
        )
      )
    ])
    error_message = "The 'cloudwatch' integration with access key must have non-empty 'region', 'access_key_id', and 'secret_access_key'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "cloudwatch_v2" || (
          lookup(val, "region", "") != "" &&
          lookup(val, "access_key_id", "") != "" &&
          lookup(val, "secret_access_key", "") != ""
        )
      )
    ])
    error_message = "The 'cloudwatch_v2' integration with access key must have non-empty 'region', 'access_key_id', and 'secret_access_key'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "cloudwatch" || (
          lookup(val, "region", "") != "" &&
          lookup(val, "iam_role", "") != "" &&
          lookup(val, "iam_external_id", "") != ""
        )
      )
    ])
    error_message = "The 'cloudwatch' integration with assume role must have non-empty 'region', 'iam_role', and 'iam_external_id'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "cloudwatch_v2" || (
          lookup(val, "region", "") != "" &&
          lookup(val, "iam_role", "") != "" &&
          lookup(val, "iam_external_id", "") != ""
        )
      )
    ])
    error_message = "The 'cloudwatch_v2' integration with assume role must have non-empty 'region', 'iam_role', and 'iam_external_id'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "datadog" || (
          lookup(val, "api_key", "") != "" &&
          lookup(val, "region", "") != ""
        )
      )
    ])
    error_message = "The 'datadog' integration must have non-empty 'api_key' and 'region'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "datadog_v2" || (
          lookup(val, "api_key", "") != "" &&
          lookup(val, "region", "") != ""
        )
      )
    ])
    error_message = "The 'datadog_v2' integration must have non-empty 'api_key' and 'region'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "librato" || (
          lookup(val, "email", "") != "" &&
          lookup(val, "api_key", "") != ""
        )
      )
    ])
    error_message = "The 'librato' integration must have non-empty 'email' and 'api_key'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "newrelic_v2" || (
          lookup(val, "api_key", "") != "" &&
          lookup(val, "region", "") != ""
        )
      )
    ])
    error_message = "The 'newrelic_v2' integration must have non-empty 'api_key' and 'region'."
  }

  validation {
    condition = alltrue([
      for key, val in var.metrics_integrations : (
        key != "stackdriver" || (
          lookup(val, "private_key", "") != "" &&
          lookup(val, "project_id", "") != "" &&
          lookup(val, "client_email", "") != ""
        )
      )
    ])
    error_message = "The 'stackdriver' integration must have non-empty 'credentials': 'private_key', 'project_id' and 'client_email' '."
  }
}


# Logs integration
variable "logs_integrations" {
  type = map(object({
    name               = string
    api_key            = optional(string)
    region             = optional(string)
    tags               = optional(map(string))
    tenant_id          = optional(string)
    application_id     = optional(string)
    application_secret = optional(string)
    dce_uri            = optional(string)
    table              = optional(string)
    dcr_id             = optional(string)
    client_email       = optional(string)
    project_id         = optional(string)
    private_key        = optional(string)
    access_key_id      = optional(string)
    endpoint           = optional(string)
    secret_access_key  = optional(string)
    application        = optional(string)
    subsystem          = optional(string)
    token              = optional(string)
    url                = optional(string)
    host               = optional(string)
    host_port          = optional(string)
    sourcetype         = optional(string)

  }))
  default = {}

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "azure_monitor" || (
          lookup(val, "tenant_id", "") != "" &&
          lookup(val, "application_id", "") != "" &&
          lookup(val, "application_secret", "") != "" &&
          lookup(val, "dce_uri", "") != "" &&
          lookup(val, "dcr_id", "") != "" &&
          lookup(val, "table", "") != ""
        )
      )
    ])
    error_message = "The 'azure_monitor' integration must have non-empty 'tenant_id', 'application_id', 'application_secret', 'dce_uri', 'dcr_id', and 'table'."
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "cloudwatch_logs" || (
          lookup(val, "access_key_id", "") != "" &&
          lookup(val, "region", "") != "" &&
          lookup(val, "secret_access_key", "") != ""
        )
      )
    ])
    error_message = "The 'cloudwatch_logs' integration must have a non-empty 'access_key_id', a non-empty 'region' list and 'secret_access_key'."
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "coralogix_logs" || (
          lookup(val, "private_key", "") != "" &&
          lookup(val, "application", "") != "" &&
          lookup(val, "subsystem", "") != ""
        )
      )
    ])
    error_message = "The 'coralix_logs' integration must have a non-empty 'private_key', 'application' and 'subsystem'"
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "datadog_logs" || (
          lookup(val, "api_key", "") != "" &&
          lookup(val, "region", "") != "" &&
          lookup(val, "tags", "") != ""
        )
      )
    ])
    error_message = "The 'datadog_logs' integration must have a non-empty 'api_key' a non-empty list of 'region' and 'tags'"
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "logentries" || (
          lookup(val, "token", "") != ""
        )
      )
    ])
    error_message = "The 'logentries' integration must have a non-empty 'token'"
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "loggly" || (
          lookup(val, "token", "") != ""
        )
      )
    ])
    error_message = "The 'loggly' integration must have a non-empty 'token'"
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "papertrail" || (
          lookup(val, "url", "") != ""
        )
      )
    ])
    error_message = "The 'papertrail' integration must have a non-empty 'url'"
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "scalyr_logs" || (
          lookup(val, "token", "") != "" &&
          lookup(val, "host", "") != ""
        )
      )
    ])
    error_message = "The 'scalyr_logs' integration must have a non-empty 'token' and 'host'."
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "splunk_logs" || (
          lookup(val, "token", "") != "" &&
          lookup(val, "host_port", "") != "" &&
          lookup(val, "sourcetype", "") != ""
        )
      )
    ])
    error_message = "The 'splung_logs' integration must have a non-empty  'token', 'host_port', and 'sourcetype'."
  }

  validation {
    condition = alltrue([
      for key, val in var.logs_integrations : (
        key != "stackdriver_logs" || (
          lookup(val, "project_id", "") != "" &&
          lookup(val, "private_key", "") != "" &&
          lookup(val, "client_email", "") != ""
        )
      )
    ])
    error_message = "The 'stackdriver_logs' integration must have a non-empty 'credentials': 'project_id', 'private_key', and 'client_email'."
  }
}

variable "cloudamqp_vpc_connect" {
  description = "CloudAMQP vpc_connect configurations"
  type = object({
    instance_id            = number
    approved_subscriptions = optional(list(string))
    sleep                  = optional(number)
    timeout                = optional(number)
  })
}
