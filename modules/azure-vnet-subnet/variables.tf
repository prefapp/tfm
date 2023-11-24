variable "virtual_networks" {
  description = "A map of virtual networks and their properties"
  type = map(object({
    location            = string
    resource_group_name = string
    address_space       = list(string)
    subnets = map(object({
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
    }))
    tags = map(string)
  }))
  default = {}
}









