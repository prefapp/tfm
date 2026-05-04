# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#name
variable "name" {
  type        = string
  description = "(Required) Name of the resource group. Changing this forces a new resource group."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#location
variable "location" {
  type        = string
  description = "(Required) Azure region for the resource group (e.g. westeurope). Changing this forces a new resource group."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group#tags
variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Tags to assign to the resource group."
}
