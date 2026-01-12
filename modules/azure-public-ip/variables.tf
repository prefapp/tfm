# Variables
variable "resource_group_name" {
  description = "The name of the resource group in which to create the public IP"
  type = string
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type = string
}

variable "location" {
  description = "The location/region where the public IP will be created"
  type = string
}

variable "public_ip_sku" {
  description = "The SKU of the public IP"
  type = string
  default = "Standard"
}

variable "public_ip_allocation_method" {
  description = "The allocation method of the public IP"
  type = string
  default = "Static"
}

variable "public_ip_domain_name_label" {
  description = "Label for the Domain Name"
  type = string
  default = null
}

variable "tags" {
  description = "A map of tags to add to the public IP"
  type = map(string)
  default = {}
}

variable "tags_from_rg" {
  description = "Use the tags from the resource group"
  type = bool
  default = true
}
