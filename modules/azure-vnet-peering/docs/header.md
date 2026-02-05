# Azure Virtual Network Peering Module

This Terraform module creates a virtual network peering between two Azure virtual networks.

## Features
- Creates peering from origin to destination VNet
- Creates peering from destination to origin VNet
- Supports custom names for each peering

## Real usage example

### Set a module

```terraform
module "azure-vnet-peering" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-peering?ref=<version>"
}
```

###############
# VNET ORIGIN #
###############

  origin_virtual_network_name      = "origen-vnet"
  origin_resource_group_name       = "test-peering"
  origin_name_peering              = "origen-vnet-to-destino-vnet"

####################
# VNET DESTINATION #
####################

  destination_virtual_network_name = "destino-vnet"
  destination_resource_group_name  = "test-peering"
  destination_name_peering         = "destino-vnet-to-origen-vnet"
}
```