variable "name" {
  description = "(Required) Name of the public IP prefix."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group where the prefix is created (must already exist)."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the public IP prefix."
  type        = string
}

variable "sku" {
  description = "(Optional) SKU of the public IP prefix. Only `Standard` is supported."
  type        = string
  nullable    = true
  default     = "Standard"
  validation {
    condition     = contains(["Standard"], var.sku)
    error_message = "The only supported value for 'sku' is 'Standard'."
  }
}

variable "sku_tier" {
  description = "(Optional) SKU tier: `Regional` or `Global`."
  type        = string
  nullable    = true
  default     = "Regional"
  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "The supported values for 'sku_tier' are 'Regional' and 'Global'."
  }
}

variable "ip_version" {
  description = "(Optional) `IPv4` or `IPv6`."
  type        = string
  nullable    = true
  default     = "IPv4"
  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "The supported values for 'ip_version' are 'IPv4' and 'IPv6'."
  }
}

variable "prefix_length" {
  description = "(Optional) Prefix length (CIDR size). Must be between 0 and 32 per variable validation; check Azure limits for your scenario."
  type        = number
  nullable    = true
  default     = 28
  validation {
    condition     = var.prefix_length >= 0 && var.prefix_length <= 32
    error_message = "The 'prefix_length' must be between 0 and 32."
  }
}

variable "zones" {
  description = "(Optional) Availability zones for the prefix (region-dependent); empty list for no zone pinning."
  type        = list(string)
  nullable    = true
  default     = []
}

variable "tags_from_rg" {
  description = "(Optional) Merge tags from the resource group with `tags` (`tags` win on key conflicts)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Tags applied to the public IP prefix."
  type        = map(string)
  default     = {}
}
