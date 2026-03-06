## VARIABLES SECTION

variable "connection" {
  description = "List of Site-to-Site VPN connection objects"
  type = list(object({
    name                       = string
    location                   = string
    resource_group_name        = string
    type                       = string
    gateway_name               = string
    enable_bgp                 = bool
    shared_key                 = optional(string)
    keyvault_secret_name       = optional(string)
    keyvault_vault_name        = optional(string)
    keyvault_vault_rg          = optional(string)
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_lifetime      = number
      sa_datasize      = number
    }) )
    tags_from_rg               = optional(bool)
    tags                       = optional(map(string))
  }))
  default = []
}

variable "local_network_gateway_id" {
  description = "Map of local network gateway IDs, indexed by connection key"
  type        = map(string)
}

