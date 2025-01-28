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
  }))
}

