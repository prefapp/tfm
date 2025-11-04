# Variables
variable "tags" {
  type = map(string)
}

variable "eventhub" {
  type = map(object({
    name                = string
    partition_count     = number
    message_retention   = number
    auth_rule_name      = string
    consumer_group_name = string
    auth_rule = object({
      listen = bool
      send   = bool
      manage = bool
    })
    event_subscription = object({
      name                 = string
      included_event_types = list(string)
      retry_ttl            = number
      max_attempts         = number
    })
    system_topic_name = string
  }))
}

variable "system_topic" {
  type = map(object({
    name               = string
    location           = string
    topic_type         = string
    source_resource_id = string
  }))
}

variable "namespace" {
  type = object({
    name                 = string
    location             = string
    resource_group_name  = string
    sku                  = string
    capacity             = number
    auto_inflate_enabled = bool
    identity_type        = string
    ruleset = object({
      default_action                 = string
      public_network_access_enabled  = bool
      trusted_service_access_enabled = bool
      virtual_network_rules = optional(list(object({
        subnet_id = string
        ignore_missing_virtual_network_service_endpoint = optional(bool)
      })))
      ip_rules = optional(list(object({
        ip_mask = string
        action  = string
      })))
    })
  })
}

