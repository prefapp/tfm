variable "name" {
  description = "The name of the Public IP Prefix."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Public IP Prefix."
  type        = string
}

variable "location" {
  description = "The location/region where the Public IP Prefix is created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Public IP Prefix."
  type        = optional(string)
  default = "Standard"
  validation {
    condition     = contains(["Standard"], var.sku)
    error_message = "The only supported value for 'sku' is 'Standard'."
  }
}

variable "sku_tier" {
  description = "The SKU tier of the Public IP Prefix."
  type        = optional(string)
  default = "Regional"
  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "The supported values for 'sku_tier' are 'Regional' and 'Global'."
  }
}

variable "ip_version" {
  description = "The IP version of the Public IP Prefix."
  type        = optional(s)
  default     = "IPv4"
  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "The supported values for 'ip_version' are 'IPv4' and 'IPv6'."
  }
}

variable "prefix_length" {
  description = "The length of the Public IP Prefix."
  type        = optional(number)
  default     = 28
  validation {
    condition     = var.prefix_length >= 0 && var.prefix_length <= 32
    error_message = "The 'prefix_length' must be between 0 and 32."
  }
}

variable "zones" {
  description = "The availability zone to allocate the Public IP Prefix in."
  type        = optional(list(string))
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = optional(map(string))
  default     = {}
}
