// Basic example: Virtual Network with one subnet using azure-vnet-and-subnet module

module "azure_vnet_and_subnet" {
  source = "../../"

  resource_group_name = "example-rg"

  virtual_network = {
    name          = "example-vnet"
    location      = "westeurope"
    address_space = ["10.0.0.0/16"]
    subnets = {
      internal = {
        address_prefixes = ["10.0.1.0/24"]
      }
    }
  }

  private_dns_zones = []
  peerings          = []

  tags = {
    environment = "dev"
  }
}

