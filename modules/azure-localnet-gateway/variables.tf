## VARIABLES SECTION

variable "localnet" {
  description = "List of Site-to-Site VPN connection objects"
  type = list(object({
    type                        = string
    resource_group_name         = string
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
    tags_from_rg                = optional(bool)
    tags                        = optional(map(string))
  }))
  default = []
}
