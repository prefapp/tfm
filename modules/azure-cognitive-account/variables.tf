variable "name" {
  description = "Name of the Cognitive Services account."
  type        = string
}

variable "location" {
  description = "Azure region where the account will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group for the account."
  type        = string
}

variable "kind" {
  description = "Kind of Cognitive Services account. Use OpenAI for Azure OpenAI accounts."
  type        = string
  default     = "OpenAI"
}

variable "sku_name" {
  description = "SKU name for the account, for example S0."
  type        = string
}

variable "custom_subdomain_name" {
  description = "Unique custom subdomain used to construct the account endpoint. Changing this may force replacement."
  type        = string
}

variable "dynamic_throttling_enabled" {
  description = "Whether to enable dynamic throttling. Leave null for OpenAI and AIServices accounts, where the provider does not allow this argument."
  type        = bool
  default     = null
}

variable "local_auth_enabled" {
  description = "Whether key-based local authentication is enabled. Disable when using Microsoft Entra ID authentication only."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the account is reachable through its public endpoint. Set false when using private endpoints."
  type        = bool
  default     = true
}

variable "outbound_network_access_restricted" {
  description = "Whether outbound network access from the account is restricted."
  type        = bool
  default     = false
}

variable "project_management_enabled" {
  description = "Enable project management features on the account."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network access rules for the account. Set default_action to Deny and use IP or virtual network rules to restrict access."
  type = object({
    bypass         = string
    default_action = string
    ip_rules       = optional(list(string), [])
    virtual_network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })

  validation {
    condition     = contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be AzureServices or None."
  }

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be Allow or Deny."
  }
}

variable "tags_from_rg" {
  description = "Whether to merge tags from the resource group with the tags supplied to this module. Module tags take precedence."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the account."
  type        = map(string)
  default     = {}
}
