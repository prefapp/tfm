locals {
  subnets = flatten([
    # Iterate over each virtual network
    for vnet in [var.virtual_network] : [
      # Iterate over each subnet in the current virtual network
      for subnet_key, subnet_value in vnet.subnets : {
        vnet_name    = vnet.name
        subnet_key   = subnet_key
        subnet_value = subnet_value
      }
    ]
  ])
}

# Resource block for creating Azure subnets
resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.subnets : "${subnet.vnet_name}.${subnet.subnet_key}" => subnet }

  name                 = each.value.subnet_key
  resource_group_name  = var.resource_group_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.subnet_value.address_prefixes

  private_link_service_network_policies_enabled = lookup(each.value.subnet_value, "private_link_service_network_policies_enabled", true)
  private_endpoint_network_policies             = each.value.subnet_value.private_endpoint_network_policies_enabled
  service_endpoints                             = lookup(each.value.subnet_value, "service_endpoints", [])

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
