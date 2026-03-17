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

variable "private_dns_zones" {
  description = "List of private DNS zones to create.\n\nEach zone can optionally define virtual_network_links (list of objects) to link the DNS zone to multiple VNets.\nIf virtual_network_links is omitted, a default link to the main VNet is created.\n\nExample:\nprivate_dns_zones = [\n  {\n    name = \"example.com\"\n    auto_registration_enabled = false\n    virtual_network_links = [\n      {\n        name = \"vnet-link-1\"\n        virtual_network_id = \"/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/vnet1\"\n      },\n      {\n        name = \"vnet-link-2\"\n        virtual_network_id = \"/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/vnet2\"\n      }\n    ]\n  },\n  {\n    name = \"other.com\"\n    auto_registration_enabled = true\n    # No virtual_network_links: will link to main VNet\n  }\n]\n"
  type = list(object({
    name                      = string
    link_name                 = optional(string)
    auto_registration_enabled = optional(bool, false)
    virtual_network_links     = optional(list(object({
      name                 = string
      virtual_network_id   = string
      virtual_network_name = optional(string)
    })))
  }))
  default = []
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
