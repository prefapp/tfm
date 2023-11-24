virtual_networks = {

  // Virtual Network 1
  vnet1 = {
    location            = "westeurope" // The Azure region where the virtual network is located
    resource_group_name = "example-resources" // The name of the resource group that the virtual network belongs to
    address_space       = ["192.20.0.0/16"] // The address space of the virtual network
    subnets = {

      // Subnet 1 with multiple address prefixes
      subnet1 = {
        address_prefixes = [
          "192.20.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = true // default
        private_link_service_network_policies_enabled = false
        service_endpoints = [ // The service endpoints that are associated with the subnet
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
        delegation = [ // The service delegations for the subnet
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.Web/serverFarms" // The name of the service that the subnet is delegated to
              actions = [ // The actions that are allowed for the service delegation
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },

      // Subnet 2 without any service endpoints or delegations
      subnet2 = {
        address_prefixes = [
          "192.20.3.0/24"
        ]
      }
      
    }
    tags = { // The tags that are associated with the virtual network
      environment = "prod"
      department  = "finance"
    }
  },

  // Virtual Network 2 with more complex subnet configurations
  vnet2 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.30.0.0/16"]
    subnets = {

      // Subnet 1
      subnet1 = {
        address_prefixes = [
          "192.30.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = true // default
        service_endpoints = [
          "Microsoft.ContainerRegistry",
          "Microsoft.KeyVault"
        ]
        delegation = [
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.ContainerInstance/containerGroups"
              actions = [
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },

      // Subnet 2
      subnet2 = {
        address_prefixes = [
          "192.30.2.0/24"
        ]
      },

      // Subnet 3
      subnet3 = {
        address_prefixes = [
          "192.30.4.0/24"
        ]
      }

    }
    tags = {
      environment = "dev"
    }
  },

  // Virtual Network 3 without any subnets
  vnet3 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.40.0.0/16"]

    subnets = {} // This virtual network does not have any subnets

    tags = {
      environment = "dev"
    }
  }
}
