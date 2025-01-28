# VARIABLES SECTION
variable "nsg" {
  description = "Network Security Group configuration"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string))
  })
}

variable "rules" {
  description = "Network Security Rule configuration"
  type = map(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    network_security_group_name  = string
    resource_group_name          = string
  }))
  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.source_port_range == null || rule.source_port_ranges == null)
      || (rule.source_port_range != null && rule.source_port_ranges == null)
      || (rule.source_port_range == null && rule.source_port_ranges != null)
    ])
    error_message = "Only one of 'source_port_range' or 'source_port_ranges' can be specified for each rule."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.destination_port_range == null || rule.destination_port_ranges == null)
      || (rule.destination_port_range != null && rule.destination_port_ranges == null)
      || (rule.destination_port_range == null && rule.destination_port_ranges != null)
    ])
    error_message = "Only one of 'destination_port_range' or 'destination_port_ranges' can be specified for each rule."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.source_address_prefix == null || rule.source_address_prefixes == null)
      || (rule.source_address_prefix != null && rule.source_address_prefixes == null)
      || (rule.source_address_prefix == null && rule.source_address_prefixes != null)
    ])
    error_message = "Only one of 'source_adress_prefix' or 'source_adress_prefixes' can be specified for each rule."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.destination_address_prefix == null || rule.destination_address_prefixes == null)
      || (rule.destination_address_prefix != null && rule.destination_address_prefixes == null)
      || (rule.destination_address_prefix == null && rule.destination_address_prefixes != null)
    ])
    error_message = "Only one of 'destination_adress_prefix' or 'destination_adress_prefixes' can be specified for each rule."
  }
}
