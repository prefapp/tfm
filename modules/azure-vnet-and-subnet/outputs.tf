output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_guid" {
  description = "GUID of the virtual network."
  value       = azurerm_virtual_network.this.guid
}

output "vnet_subnets" {
  description = "Full subnet objects keyed by <vnet_name>.<subnet_name>."
  value = {
    for k, s in azurerm_subnet.subnet :
    k => {
      id                = s.id
      name              = s.name
      address_prefixes  = s.address_prefixes
    }
  }
}

output "subnet_ids" {
  description = "Map from subnet composite keys (`<vnet_name>.<subnet_name>`) to subnet resource IDs."
  value       = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

output "private_dns_zone_ids" {
  description = "Map from private DNS zone name (for_each key) to private DNS zone resource ID."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "private_dns_zones" {
  description = "Private DNS zones keyed by name."
  value = {
    for k, z in azurerm_private_dns_zone.this :
    k => {
      id   = z.id
      name = z.name
    }
  }
}

output "private_dns_zone_virtual_network_link_ids" {
  description = "Map from VNet link for_each keys (zone name when linking this VNet, or `<zone_name>-<link_name>` for other VNets) to private DNS zone virtual network link resource ID."
  value       = { for k, link in azurerm_private_dns_zone_virtual_network_link.this : k => link.id }
}

output "vnet_peering_ids" {
  description = "Map from peering name to virtual network peering resource ID."
  value       = { for name, peering in azurerm_virtual_network_peering.this : name => peering.id }
}
