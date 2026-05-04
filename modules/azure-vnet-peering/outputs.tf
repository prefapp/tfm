output "destination_name_peering_output" {
  description = "Peering name on the destination virtual network (destination → origin)."
  value       = var.destination_name_peering
}

output "destination_resource_group_name_output" {
  description = "Resource group name of the destination virtual network."
  value       = var.destination_resource_group_name
}

output "destination_virtual_network_name_output" {
  description = "Name of the destination virtual network."
  value       = var.destination_virtual_network_name
}

output "origin_name_peering_output" {
  description = "Peering name on the origin virtual network (origin → destination)."
  value       = var.origin_name_peering
}

output "origin_resource_group_name_output" {
  description = "Resource group name of the origin virtual network."
  value       = var.origin_resource_group_name
}

output "origin_virtual_network_name_output" {
  description = "Name of the origin virtual network."
  value       = var.origin_virtual_network_name
}
