output "network_id" {
  description = "OVHcloud ID (pn-...) of the private network."
  value       = ovh_cloud_project_network_private.kubernetes.id
}

output "network_openstack_id" {
  description = "Regional OpenStack network ID for consumers that accept resource IDs directly; ovh-mks discovers the network by name."
  value       = one(ovh_cloud_project_network_private.kubernetes.regions_attributes[*].openstackid)
}

output "subnet_id" {
  description = "OVHcloud ID of the DHCP subnet for consumers that require resource IDs directly; ovh-mks discovers the subnet by CIDR."
  value       = ovh_cloud_project_network_private_subnet.kubernetes.id
}

output "gateway_id" {
  description = "ID of the gateway attached to the private network."
  value       = ovh_cloud_project_gateway.kubernetes.id
}

output "service_name" {
  description = "OVHcloud service_name of the resolved Public Cloud project."
  value       = local.service_name
}
