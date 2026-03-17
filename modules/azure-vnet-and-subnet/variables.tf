variable "virtual_network" {
  description = "Properties of the virtual network"
  type = object({
    name          = string
    location      = string
    address_space = list(string)
    subnets = map(object({
      address_prefixes                              = list(string)
      private_endpoint_network_policies_enabled     = optional(string, "Enabled")
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

variable "peerings" {
  description = "List of virtual network peerings"
  type = list(object({
    peering_name                 = string
    allow_forwarded_traffic      = optional(bool, false)
  description = "The tags to associate with your resources"
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type        = bool
  default     = true
}
