###############
# VNET ORIGIN #
###############

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#name
variable "origin_virtual_network_name" {
  type = string
  description = "(Required) The name of the origin virtual network. Changing this forces a new resource to be created."
}

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#resource_group_name
variable "origin_resource_group_name" {
  type = string
  description = "(Required) The name of the resource group in which to create the origin virtual network. Changing this forces a new resource to be created."
}

# (Resource) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering#name
variable "origin_name_peering" {
  type = string
  description = "(Required) The name of the origin to destination peering. Changing this forces a new resource to be created."
}

####################
# VNET DESTINATION #
####################

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#name
variable "destination_virtual_network_name" {
  type = string
  description = "(Required) The name of the destination virtual network. Changing this forces a new resource to be created."
}

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#resource_group_name
variable "destination_resource_group_name" {
  type = string
  description = "(Required) The name of the resource group in which to create the destination virtual network. Changing this forces a new resource to be created."
}

# (Resource) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering#name
variable "destination_name_peering" {
  type = string
  description = "(Required) The name of the destination to origin peering. Changing this forces a new resource to be created."
}
