## VARIABLES SECTION
variable "vpn" {
  description = "VPN Gateway configuration object (includes P2S config)"
  type = object({
    location                = string
    resource_group_name     = string
    gateway_name            = string
    ip_name                 = string
    public_ip_id            = string
    ip_allocation_method    = string
    gateway_subnet_id       = string
    type                    = string
    vpn_type                = string
    active_active           = bool
    enable_bgp              = bool
    sku                     = string
    custom_route_address_prefixes = list(string)
    vpn_client_address_space = list(string)
    vpn_client_protocols     = list(string)
    vpn_client_aad_audience  = string
    vpn_client_aad_issuer    = string
    vpn_client_aad_tenant    = string
    root_certificates        = list(object({
      name        = string
      public_cert = string
    }))
    connection_name          = string
    vpn_client_address_pool  = list(string)
  })
  default = {}
}

variable "s2s" {
  description = "List of Site-to-Site VPN connection objects"
  type = list(object({
    type                        = string
    gateway_name                = string
    gateway_sku                 = string
    ip_name                     = string
    gateway_subnet_id           = string
    public_ip_id                = string
    enable_bgp                  = bool
    local_gateway_name          = string
    local_gateway_ip            = string
    local_gateway_address_space = list(string)
    connection_name             = string
    shared_key                  = string
  }))
    default = []
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
