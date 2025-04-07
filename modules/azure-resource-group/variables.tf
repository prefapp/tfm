# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#name
variable "name" {
  type        = string
  default     = ""
  description = "(Required) The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#location
variable "location" {
  type        = string
  default     = ""
  description = "(Required) The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#tags
variable "tags" {
  type        = map(any)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to the Resource Group."
}
