// Basic example: bidirectional VNet peering between two VNets

module "azure_vnet_peering" {
  source = "../../"

  origin_virtual_network_name  = "hub-vnet"
  origin_resource_group_name   = "network-rg"
  origin_name_peering          = "hub-to-spoke"

  destination_virtual_network_name = "spoke-vnet"
  destination_resource_group_name  = "network-rg"
  destination_name_peering         = "spoke-to-hub"
}

