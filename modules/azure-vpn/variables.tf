## VARIABLES SECTION
variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_gw_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vpn_ip_name" {
  type = string
}

variable "vpn_ip_allocation_method" {
  type = string
}

variable "vpn_ip_sku" {
  type = string
}

variable "vpn_gw_name" {
  type = string
}

variable "vpn_gw_type" {
  type = string
}

variable "vpn_gw_vpn_type" {
  type = string
}

variable "vpn_gw_active_active" {
  type = bool
}

variable "vpn_gw_enable_bgp" {
  type = bool
}

variable "vpn_gw_sku" {
  type = string
}

variable "vpn_gw_client_configuration_public_cert_data" {
  type = string
}

variable "vpn_gw_client_configuration_public_cert_data-2025" {
  type = string
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
