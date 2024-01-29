# VNET outputs
output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

# Subnets output
output "subnets" {
  value = { for subnet_key, subnet_value in azurerm_subnet.subnet : subnet_key => {
    id                                            = subnet_value.id
    address_prefixes                              = subnet_value.address_prefixes
    network_policies_enabled                      = subnet_value.private_endpoint_network_policies_enabled
    private_link_service_network_policies_enabled = subnet_value.private_link_service_network_policies_enabled
    service_endpoints                             = subnet_value.service_endpoints
    }
  }
}
