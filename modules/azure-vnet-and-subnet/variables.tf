variable "virtual_network" {
  description = "Properties of the virtual network"
  type = object({
    name          = string
    location      = string
    address_space = list(string)
    subnets = map(object({
      address_prefixes                              = list(string)
      private_endpoint_network_policies_enabled     = optional(string, "Disabled")
      private_link_service_network_policies_enabled = optional(bool, true)
      service_endpoints                             = optional(list(string))
      delegation = optional(list(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      })))
    }))
  })
}

variable "private_dns_zones" {
  description = "List of private DNS zones to create"
  type = list(object({
    name = string
  }))
  default = []
}

variable "private_dns_zone_virtual_network_links" {
  description = "Map of private DNS zone virtual network links"
  type = map(object({
    name                  = string
    private_dns_zone_name = string
    registration_enabled  = optional(bool, false)
  }))
  default = {}
}

variable "peerings" {
  description = "List of virtual network peerings"
  type = list(object({
    peering_name                 = string
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    allow_virtual_network_access = bool
    use_remote_gateways          = bool
    resource_group_name          = string
    vnet_name                    = string
    remote_virtual_network_id    = string
  }))
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}

variable "tags" {
  description = "The tags to associate with your resources"
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type        = bool
  default     = true
}
