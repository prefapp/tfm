## VARIABLES SECTION

variable "vpn" {
  description = "VPN Gateway link configuration object variables"
  type = object({
    gateway_name        = string
    resource_group_name = string
  })
}

variable "connection" {
  description = "List of Site-to-Site VPN connection objects"
  type = list(object({
    type                        = string
    gateway_name                = string
    gateway_sku                 = string
    location                    = string
    ip_name                     = string
    enable_bgp                  = bool
    local_gateway_name          = string
    local_gateway_ip            = string
    local_gateway_address_space = list(string)
    connection_name             = string
    shared_key                  = optional(string)
    # Optional: fetch shared_key from Key Vault
    keyvault_secret_name        = optional(string)
    keyvault_vault_name         = optional(string)
    keyvault_vault_rg           = optional(string)
    # Optional: advanced IPsec policy
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_lifetime      = number
    }))
  }))
  default = []
}

variable "nat_rules" {
  description = "List of NAT rules for the VPN gateway"
  type = list(object({
    name                           = string
    mode                           = string
    type                           = string
    ip_configuration_id            = string
    external_mapping_address_space = string
    internal_mapping_address_space = string
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
