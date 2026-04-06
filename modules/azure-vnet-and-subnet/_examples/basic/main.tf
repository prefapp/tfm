// Basic example: Virtual Network with one subnet using azure-vnet-and-subnet module

locals {
  values = yamldecode(file("./values.yaml"))
}

module "azure_vnet_and_subnet" {
  source = "../../"

  resource_group_name = local.values.resource_group_name
  virtual_network     = local.values.virtual_network
  private_dns_zones   = local.values.private_dns_zones
  peerings            = local.values.peerings
}