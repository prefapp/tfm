# Azure virtual network(s) and subnet(s)

## Overview

This module creates one or more virtual networks and subnets.

## DOC

- [Resource terraform - azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Resource terraform - azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)

## Usage

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=<version>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=v1.2.3"
}
```

### Set a data input.yaml

#### Example with comments

```yaml
# This YAML file is used to define the configuration for Azure Virtual Networks and their Subnets

# Virtual Network 1 with complex subnet configurations
vnet1:
  location: "westeurope"
  resource_group_name: "example-resources"
  address_space:
    - "192.20.0.0/16"
  subnets:
    # Subnet 1 with multiple address prefixes
    subnet1:
      address_prefixes:
        - "192.20.1.0/24"
      private_endpoint_network_policies_enabled: true # default
      private_link_service_network_policies_enabled: false
      service_endpoints:
        - "Microsoft.Storage"
        - "Microsoft.Sql"
      delegation:
        - name: "delegation"
          service_delegation:
            name: "Microsoft.Web/serverFarms"
            actions:
              - "Microsoft.Network/virtualNetworks/subnets/action"
    # Subnet 2 without any service endpoints or delegations
    subnet2:
      address_prefixes:
        - "192.20.3.0/24"
  tags:
    environment: "prod"
    department: "finance"

# Virtual Network 2 with more complex subnet configurations
vnet2:
  # The Azure region where the virtual network is located
  location: "westeurope"
  # The name of the resource group that the virtual network belongs to
  resource_group_name: "example-resources"
  # The address space of the virtual network
  address_space:
    - "192.30.0.0/16"
  # The subnets within the virtual network
  subnets:
    # Subnet 1
    subnet1:
      # The address prefixes for the subnet
      address_prefixes:
        - "192.30.1.0/24"
      # Whether network policies are enabled for private endpoints in the subnet
      private_endpoint_network_policies_enabled: false
      # Whether network policies are enabled for private link services in the subnet
      private_link_service_network_policies_enabled: true # default
      # The service endpoints that are associated with the subnet
      service_endpoints:
        - "Microsoft.ContainerRegistry"
        - "Microsoft.KeyVault"
      # The service delegations for the subnet
      delegation:
        - name: "delegation"
          service_delegation:
            # The name of the service that the subnet is delegated to
            name: "Microsoft.ContainerInstance/containerGroups"
            # The actions that are allowed for the service delegation
            actions:
              - "Microsoft.Network/virtualNetworks/subnets/action"
    # Subnet 2
    subnet2:
      address_prefixes:****
        - "192.30.2.0/24"
    # Subnet 3
    subnet3:
      address_prefixes:
        - "192.30.4.0/24"
  # The tags that are associated with the virtual network
  tags:
    environment: "dev"

# Virtual Network 3 with no subnets
vnet3:
  location: "westeurope"
  resource_group_name: "example-resources"
  address_space:
    - "192.40.0.0/16"
  # This virtual network does not have any subnets
  subnets: {}
  tags:
    environment: "dev"
```

#### Example without comments

```yaml
vnet1:
  location: "westeurope"
  resource_group_name: "example-resources"
  address_space:
    - "192.20.0.0/16"
  subnets:
    subnet1:
      address_prefixes:
        - "192.20.1.0/24"
      private_endpoint_network_policies_enabled: true
      private_link_service_network_policies_enabled: false
      service_endpoints:
        - "Microsoft.Storage"
        - "Microsoft.Sql"
      delegation:
        - name: "delegation"
          service_delegation:
            name: "Microsoft.Web/serverFarms"
            actions:
              - "Microsoft.Network/virtualNetworks/subnets/action"
    subnet2:
      address_prefixes:
        - "192.20.3.0/24"
  tags:
    environment: "prod"
    department: "finance"

vnet2:
  location: "westeurope"
  resource_group_name: "example-resources"
  address_space:
    - "192.30.0.0/16"
  subnets:
    subnet1:
      address_prefixes:
        - "192.30.1.0/24"
      private_endpoint_network_policies_enabled: false
      private_link_service_network_policies_enabled: true
      service_endpoints:
        - "Microsoft.ContainerRegistry"
        - "Microsoft.KeyVault"
      delegation:
        - name: "delegation"
          service_delegation:
            name: "Microsoft.ContainerInstance/containerGroups"
            actions:
              - "Microsoft.Network/virtualNetworks/subnets/action"
    subnet2:
      address_prefixes:
        - "192.30.2.0/24"
    subnet3:
      address_prefixes:
        - "192.30.4.0/24"
  tags:
    environment: "dev"

vnet3:
  location: "westeurope"
  resource_group_name: "example-resources"
  address_space:
    - "192.40.0.0/16"
  subnets: {}
  tags:
    environment: "dev"
```

## Output

```output
######################################
#### Virtual Networks and Subnets ####
######################################

Virtual Network Name: vnet1
Virtual Network ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1
Virtual Network Location: westeurope
Virtual Network Address Space: ["192.20.0.0/16"]
Virtual Network Tags: {"department":"finance","environment":"prod"}
Subnets:
         - subnet1
                - Subnet Name: subnet1
                - Subnet ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1
                - Subnet Address Prefixes: ["192.20.1.0/24"]
                - Subnet Network Policies Enabled: true
                - Subnet Private Link Service Network Policies Enabled: false
                - Subnet Service Endpoints: ["Microsoft.Sql","Microsoft.Storage"]
         - subnet2
                - Subnet Name: subnet2
                - Subnet ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet2
                - Subnet Address Prefixes: ["192.20.3.0/24"]
                - Subnet Network Policies Enabled: true
                - Subnet Private Link Service Network Policies Enabled: true
                - Subnet Service Endpoints: []

Virtual Network Name: vnet2
Virtual Network ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet2
Virtual Network Location: westeurope
Virtual Network Address Space: ["192.30.0.0/16"]
Virtual Network Tags: {"environment":"dev"}
Subnets:
         - subnet1
                - Subnet Name: subnet1
                - Subnet ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet1
                - Subnet Address Prefixes: ["192.30.1.0/24"]
                - Subnet Network Policies Enabled: false
                - Subnet Private Link Service Network Policies Enabled: true
                - Subnet Service Endpoints: ["Microsoft.ContainerRegistry","Microsoft.KeyVault"]
         - subnet2
                - Subnet Name: subnet2
                - Subnet ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet2
                - Subnet Address Prefixes: ["192.30.2.0/24"]
                - Subnet Network Policies Enabled: true
                - Subnet Private Link Service Network Policies Enabled: true
                - Subnet Service Endpoints: []
         - subnet3
                - Subnet Name: subnet3
                - Subnet ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet3
                - Subnet Address Prefixes: ["192.30.4.0/24"]
                - Subnet Network Policies Enabled: true
                - Subnet Private Link Service Network Policies Enabled: true
                - Subnet Service Endpoints: []

Virtual Network Name: vnet3
Virtual Network ID: /subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet3
Virtual Network Location: westeurope
Virtual Network Address Space: ["192.40.0.0/16"]
Virtual Network Tags: {"environment":"dev"}
Subnets:
```
