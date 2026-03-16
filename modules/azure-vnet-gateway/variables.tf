## VARIABLES SECTION

variable "vpn" {
  description = "VPN Gateway configuration object (includes P2S config)"
  type = object({
    vnet_name           = optional(string)
    gateway_subnet_name = optional(string)
    location            = string
    resource_group_name = string
    gateway_name        = string
    ip_configurations = list(object({
      name                          = string
      public_ip_name                = optional(string)
      public_ip_id                  = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
    }))
    gateway_subnet_id                     = optional(string)
    type                                  = string
    vpn_type                              = optional(string)
    active_active                         = optional(bool)
    bgp_enabled                           = optional(bool)
    sku                                   = string
    generation                            = optional(string)
    default_local_network_gateway_id      = optional(string)
    edge_zone                             = optional(string)
    private_ip_address_enabled            = optional(bool)
    bgp_route_translation_for_nat_enabled = optional(bool)
    dns_forwarding_enabled                = optional(bool)
    ip_sec_replay_protection_enabled      = optional(bool)
    remote_vnet_traffic_enabled           = optional(bool)
    virtual_wan_traffic_enabled           = optional(bool)

    # custom_route block
    custom_route_address_prefixes = optional(list(string), [])

    # vpn_client_configuration block
    vpn_client_address_space = optional(list(string), [])
    vpn_client_protocols     = optional(list(string), [])
    vpn_client_aad_tenant    = optional(string)
    vpn_client_aad_audience  = optional(string)
    vpn_client_aad_issuer    = optional(string)
    root_certificates = optional(list(object({
      name             = string
      public_cert      = optional(string)
      public_cert_data = optional(string)
    })), [])
    revoked_certificates = optional(list(object({
      name       = string
      thumbprint = string
    })), [])
    vpn_auth_types = optional(list(string), [])

    # bgp_settings block
    bgp_settings = optional(object({
      asn         = optional(number)
      peer_weight = optional(number)
      peering_addresses = optional(list(object({
        ip_configuration_name = optional(string)
        apipa_addresses       = optional(list(string))
      })), [])
    }))

    # timeouts block
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition = (
      (try(var.vpn.gateway_subnet_id, null) != null || (try(var.vpn.gateway_subnet_name, null) != null && try(var.vpn.vnet_name, null) != null))
      && alltrue([
        for ipconf in var.vpn.ip_configurations : (
          try(ipconf.public_ip_id, null) != null || try(ipconf.public_ip_name, null) != null
        )
      ])
    )
    error_message = "You must provide either gateway_subnet_id or both gateway_subnet_name and vnet_name, and for each ip_configuration either public_ip_id or public_ip_name."
  }

  validation {
    condition = (
      try(var.vpn.bgp_settings, null) == null || try(var.vpn.bgp_enabled, false) == true
    )
    error_message = "If bgp_settings is set, bgp_enabled must be true."
  }

  validation {
    condition = (
      (var.vpn.type == "Vpn" && try(var.vpn.vpn_type, null) != null) ||
      (var.vpn.type != "Vpn" && try(var.vpn.vpn_type, null) == null)
    )
    error_message = "When vpn.type is \"Vpn\", vpn_type must be provided. For other gateway types, vpn_type must not be set."
  }

  validation {
    condition = alltrue([
      for rc in try(var.vpn.root_certificates, []) : (
        (
          try(rc.public_cert, null) != null &&
          try(rc.public_cert_data, null) == null
        ) ||
        (
          try(rc.public_cert, null) == null &&
          try(rc.public_cert_data, null) != null
        )
      )
    ])
    error_message = "For each root_certificate, you must provide exactly one of public_cert or public_cert_data."
  }
}

variable "nat_rules" {
  description = "List of NAT rules to apply to the VPN Gateway. Each rule must have: name, mode, type, external_mapping, and internal_mapping. Optional field is ip_configuration_id. external_mapping and internal_mapping are lists of mappings with address_space and optional port_range. mode and type are required."
  type = list(object({
    name                = string
    mode                = string
    type                = string
    ip_configuration_id = optional(string)
    external_mapping = list(object({
      address_space = string
      port_range    = optional(string)
    }))
    internal_mapping = list(object({
      address_space = string
      port_range    = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.nat_rules :
      length(rule.external_mapping) > 0 && length(rule.internal_mapping) > 0
    ])
    error_message = "Each NAT rule must have at least one external_mapping and one internal_mapping."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "If true, inherit tags from the resource group."
  type        = bool
  default     = false
}
