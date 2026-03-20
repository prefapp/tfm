variable "dns_zone_name" {
  description = "Name of the Azure Private DNS Zone."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where DNS zone will be created."
  type        = string
}

variable "vnet_ids" {
  description = "Map of VNet IDs to link to the DNS zone."
  type        = map(string)
}

variable "link_name_prefix" {
  description = "Prefix for the DNS zone link names."
  type        = string
  default     = "dnslink"
}

variable "registration_enabled" {
  description = "Whether registration is enabled for the link."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Private DNS zone."
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type        = bool
  default     = false
}
