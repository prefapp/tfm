# VNET variables
variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "location" {
  description = "The location/region where the virtual network is created"
  type        = string
}

variable "resource_group" {
  description = "The name of the resource group where the virtual network is created"
  type        = string
}

variable "address_spaces" {
  description = "The address spaces that will be used by the virtual network"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the virtual network"
  type        = map(string)
  default     = {}
}

# Subnets variable
variable "subnets" {
  description = "A map of subnets and their properties"
  type = map(object({ # The subnet name will be the key of the map
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    service_endpoints                             = optional(list(string))
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })))
    network_security_group = optional(object({
      name = string
      security_rules = list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      }))
    }))
  }))
  default = {}
}
