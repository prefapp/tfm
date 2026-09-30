output "network_id" {
  description = "ID OVHcloud (pn-...) de la red privada."
  value       = ovh_cloud_project_network_private.kubernetes.id
}

output "network_openstack_id" {
  description = "ID regional OpenStack de la red, requerido por el clúster MKS."
  value       = one(ovh_cloud_project_network_private.kubernetes.regions_attributes[*].openstackid)
}

output "subnet_id" {
  description = "ID OVHcloud de la subred DHCP, requerido como nodes_subnet_id por MKS."
  value       = ovh_cloud_project_network_private_subnet.kubernetes.id
}

output "gateway_id" {
  description = "ID del gateway asociado a la red privada."
  value       = ovh_cloud_project_gateway.kubernetes.id
}

output "service_name" {
  description = "service_name OVHcloud del proyecto Public Cloud resuelto."
  value       = local.service_name
}
