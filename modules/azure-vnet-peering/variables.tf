###############
# VNET ORIGIN #
###############

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#name
variable "origin_virtual_network_name" {
  type        = string
  description = "(Required) Name of the existing origin virtual network to look up. This module does not create the VNet."
}

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#resource_group_name
variable "origin_resource_group_name" {
  type        = string
  description = "(Required) Resource group that contains the existing origin virtual network (used for the data source lookup and as `resource_group_name` on the origin→destination peering)."
}

# (Resource) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering#name
variable "origin_name_peering" {
  type        = string
  description = "(Required) Name of the origin→destination virtual network peering resource on the origin VNet. Changing this forces a new peering to be created."
}

####################
# VNET DESTINATION #
####################

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#name
variable "destination_virtual_network_name" {
  type        = string
  description = "(Required) Name of the existing destination virtual network to look up. This module does not create the VNet."
}

# (Data) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network#resource_group_name
variable "destination_resource_group_name" {
  type        = string
  description = "(Required) Resource group that contains the existing destination virtual network (used for the data source lookup and as `resource_group_name` on the destination→origin peering)."
}

# (Resource) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering#name
variable "destination_name_peering" {
  type        = string
  description = "(Required) Name of the destination→origin virtual network peering resource on the destination VNet. Changing this forces a new peering to be created."
}
