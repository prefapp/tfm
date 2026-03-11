## VARIABLES SECTION

variable "connection" {
  description = "List of Site-to-Site VPN connection objects"
  type = list(object({
    name                               = string
    location                           = string
    resource_group_name                = string
    local_gateway_name                 = optional(string)
    local_gateway_resource_group_name  = optional(string)
    type                               = string
    gateway_name                       = string
    shared_key                         = optional(string)
    keyvault_secret_name               = optional(string)
    keyvault_vault_name                = optional(string)
    keyvault_vault_rg                  = optional(string)
    virtual_network_gateway_id         = optional(string)
    local_network_gateway_id           = optional(string)
    connection_protocol                = optional(string)
    routing_weight                     = optional(number)
    authorization_key                  = optional(string)
    express_route_circuit_id           = optional(string)
    peer_virtual_network_gateway_id    = optional(string)
    use_policy_based_traffic_selectors = optional(bool)
    express_route_gateway_bypass       = optional(bool)
    bgp_enabled                       = optional(bool)
    dpd_timeout_seconds                = optional(number)
    connection_mode                    = optional(string)
    tags_from_rg                       = optional(bool)
    egress_nat_rule_ids                = optional(list(string))
    ingress_nat_rule_ids               = optional(list(string))
    local_azure_ip_address_enabled     = optional(bool)
    tags                               = optional(map(string))
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_lifetime      = number
      sa_datasize      = optional(number)
    }))
    custom_bgp_addresses = optional(object({
      primary   = string
      secondary = optional(string)
    }))
    private_link_fast_path_enabled = optional(bool)
    traffic_selector_policy = optional(list(object({
      local_address_cidrs  = list(string)
      remote_address_cidrs = list(string)
    })))
  }))
  default = []
}


