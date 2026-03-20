variable "dns_zone_name" {
  description = "Name of the Azure DNS Zone."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where DNS zone will be created."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the DNS zone."
  type        = map(string)
  default     = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type        = bool
  default     = false
}
