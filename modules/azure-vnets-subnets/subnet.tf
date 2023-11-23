# Decode the YAML file into a Terraform data structure
locals {
  input = yamldecode(data.local_file.input.content)

  # Local variable that flattens the structure of subnets
  subnets = flatten([
    # Iterate over each virtual network
    for vnet_key, vnet_value in local.input : [
      # Iterate over each subnet in the current virtual network
      for subnet_key, subnet_value in vnet_value.subnets : {
        vnet_key     = vnet_key
        subnet_key   = subnet_key
        subnet_value = subnet_value
      }
    ]
  ])
}


# Resource block for creating Azure subnets
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  # Use the flattened subnets structure for creating each subnet
  for_each = { for subnet in local.subnets : "${subnet.vnet_key}.${subnet.subnet_key}" => subnet }

  name                 = each.value.subnet_key
  resource_group_name  = azurerm_virtual_network.vnet[each.value.vnet_key].resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  
  # Use the lookup function to get the value of these attributes from the subnet definition, 
  # and use a default value if the attribute is not specified
  private_endpoint_network_policies_enabled     = lookup(each.value.subnet_value, "private_endpoint_network_policies_enabled", true)
  private_link_service_network_policies_enabled = lookup(each.value.subnet_value, "private_link_service_network_policies_enabled", true)
  service_endpoints                             = lookup(each.value.subnet_value, "service_endpoints", [])
  address_prefixes                              = each.value.subnet_value.address_prefixes

  # Dynamic block for creating service delegations
  dynamic "delegation" {
    # Use the lookup function to get the list of delegations from the subnet definition, 
    # and use an empty list if the delegation attribute is not specified
    # It’s important to note that while you can have more than one delegation block in a subnet,
    # all delegations in a subnet must be for the same service. For instance,
    # you can’t have a delegation for Microsoft.ContainerInstance/containerGroups
    # and another for Microsoft.Web/serverFarms in the same subnet.
    for_each = lookup(each.value.subnet_value, "delegation", [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  # Specify that this resource depends on the azurerm_virtual_network resource
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
