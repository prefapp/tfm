variable "tags_from_rg" {
  description = "When true, merge tags from the resource group with `tags` (module tags win on key conflicts)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the Event Hubs namespace, Event Grid system topics, and related taggable resources in this module."
  type        = map(string)
  default     = {}
}

variable "eventhub" {
  type = map(object({
    name                 = string
    partition_count      = number
    message_retention    = number
    consumer_group_names = list(string)
    auth_rules = list(object({
      name   = string
      listen = bool
      send   = bool
      manage = bool
    }))
    event_subscription = optional(object({
      name                 = string
      included_event_types = list(string)
      retry_ttl            = number
      max_attempts         = number
    }))
    system_topic_name = optional(string)
  }))
  description = <<-EOT
    Map of event hubs to create inside the namespace. Map keys are internal identifiers used for consumer groups,
    authorization rules, and Event Grid wiring. To enable Event Grid delivery for a hub, set both `event_subscription`
    and `system_topic_name` (matching a key in `system_topic`).
  EOT
}

variable "system_topic" {
  type = map(object({
    name               = string
    location           = string
    topic_type         = string
    source_resource_id = string
  }))
  description = "Event Grid system topics keyed by name referenced from `eventhub.*.system_topic_name`. Use an empty map `{}` when Event Grid is not used."
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
        subnet_id                                       = string
        ignore_missing_virtual_network_service_endpoint = optional(bool)
      })), [])
      ip_rules = optional(list(object({
        ip_mask = string
        action  = string
      })), [])
    })
  })
  description = "Event Hubs namespace configuration, including SKU, capacity, managed identity type, and `network_rulesets` inputs."
}
