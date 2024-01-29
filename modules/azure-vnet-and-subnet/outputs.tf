output "vnet" {
  id = vnet_value.id
  location = vnet_value.location
  address_space = vnet_value.address_space
  tags = vnet_value.tags
}

output "subnet" {
  value = { for subnet_key, subnet_value in azurerm_subnet.subnet : subnet_key => {
    id = subnet_value.id
    address_prefixes = subnet_value.address_prefixes
    network_policies_enabled = subnet_value.private_endpoint_network_policies_enabled
    private_link_service_network_policies_enabled = subnet_value.private_link_service_network_policies_enabled
    service_endpoints = subnet_value.service_endpoints
  }}
}
