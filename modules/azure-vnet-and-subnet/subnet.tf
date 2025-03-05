# Local variable that flattens the structure of subnets
locals {
  subnets = flatten([
    # Iterate over each virtual network
    for vnet_key, vnet_value in var.virtual_network : [
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
resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.subnets : "${subnet.vnet_key}.${subnet.subnet_key}" => subnet }

  name                 = each.value.subnet_key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[each.value.vnet_key].name
  address_prefixes     = each.value.subnet_value.address_prefixes

  # Use the lookup function to get the list of delegations from the subnet definition,
  # and use an empty list if the delegation attribute is not specified
  # It’s important to note that while you can have more than one delegation block in a subnet,
  # all delegations in a subnet must be for the same service. For instance,
  # you can’t have a delegation for Microsoft.ContainerInstance/containerGroups
  # and another for Microsoft.Web/serverFarms in the same subnet.
  private_endpoint_network_policies_enabled     = lookup(each.value.subnet_value, "private_endpoint_network_policies_enabled", true)
  private_link_service_network_policies_enabled = lookup(each.value.subnet_value, "private_link_service_network_policies_enabled", true)
  service_endpoints                             = lookup(each.value.subnet_value, "service_endpoints", [])

  # Dynamic block for creating service delegations
  dynamic "delegation" {
    for_each = each.value.subnet_value.delegation != null ? each.value.subnet_value.delegation : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  depends_on = [
    azurerm_virtual_network.this
  ]
}
