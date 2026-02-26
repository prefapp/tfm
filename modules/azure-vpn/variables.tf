## VARIABLES SECTION
variable "vpn" {
  description = "VPN Gateway configuration object (includes P2S config)"
  type = object({
    vnet_name                = string
    gateway_subnet_name      = string
    location                 = string
    resource_group_name      = string
    gateway_name             = string
    ip_name                  = string
    public_ip_name           = string
    public_ip_id             = optional(string)
    ip_allocation_method     = string
    gateway_subnet_id        = optional(string)
    type                     = string
    vpn_type                 = string
    active_active            = bool
    enable_bgp               = bool
    sku                      = string
    generation               = optional(string)
    default_local_network_gateway_id = optional(string)
    edge_zone                = optional(string)
    private_ip_address_enabled = optional(bool)
    bgp_route_translation_for_nat_enabled = optional(bool)
    dns_forwarding_enabled   = optional(bool)
    ip_sec_replay_protection_enabled = optional(bool)
    remote_vnet_traffic_enabled = optional(bool)
    virtual_wan_traffic_enabled = optional(bool)

    # ip_configuration block fields
    private_ip_address_allocation = optional(string)

    # custom_route block
    custom_route_address_prefixes = optional(list(string), [])

    # vpn_client_configuration block
    vpn_client_address_space = optional(list(string), [])
    vpn_client_protocols     = optional(list(string), [])
    vpn_client_aad_tenant    = optional(string)
    vpn_client_aad_audience  = optional(string)
    vpn_client_aad_issuer    = optional(string)
    root_certificates        = optional(list(object({
      name            = string
      public_cert     = optional(string)
      public_cert_data = optional(string)
    })), [])
    revoked_certificates     = optional(list(object({
      name       = string
      thumbprint = string
    })), [])
    vpn_auth_types           = optional(list(string), [])

    # bgp_settings block
    bgp_settings = optional(object({
      asn          = optional(number)
      peer_weight  = optional(number)
      peering_addresses = optional(list(object({
        ip_configuration_name = optional(string)
        apipa_addresses      = optional(list(string))
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
}

variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
