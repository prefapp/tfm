output "unified_output" {
  value = <<-EOT

    ######################################
    #### Virtual Networks and Subnets ####
    ######################################

    ${join("\n", [
  for vnet_key, vnet_value in azurerm_virtual_network.vnet :
  format(
    "Virtual Network Name: %s\nVirtual Network ID: %s\nVirtual Network Location: %s\nVirtual Network Address Space: %s\nVirtual Network Tags: %s\nSubnets:\n%s\n",
    vnet_key,
    vnet_value.id,
    vnet_value.location,
    jsonencode(vnet_value.address_space),
    jsonencode(vnet_value.tags),
    join("\n", [
      for subnet_key, subnet_value in azurerm_subnet.subnet :
      format(
        "\t - %s\n \t\t- Subnet Name: %s\n\t\t- Subnet ID: %s\n\t\t- Subnet Address Prefixes: %s\n\t\t- Subnet Network Policies Enabled: %s\n\t\t- Subnet Private Link Service Network Policies Enabled: %s\n\t\t- Subnet Service Endpoints: %s",
        split(".", subnet_key)[1],
        split(".", subnet_key)[1],
        subnet_value.id,
        jsonencode(subnet_value.address_prefixes),
        subnet_value.private_endpoint_network_policies_enabled,
        subnet_value.private_link_service_network_policies_enabled,
        jsonencode(subnet_value.service_endpoints)
      ) if subnet_value.virtual_network_name == vnet_key
    ])
  )
])}
  EOT
}
