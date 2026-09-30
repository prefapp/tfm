locals {
  selected_projects = [
    for project in data.ovh_cloud_projects.projects.projects : project
    if var.project_id != null ? (
      project.project_id == var.project_id || project.service_name == var.project_id
      ) : (
      lower(project.project_name) == lower(var.project_name) || lower(project.description) == lower(var.project_name)
    )
  ]
  service_name = try(one(local.selected_projects).service_name, null)

  selected_networks = try([
    for network in data.ovh_cloud_project_network_privates.networks[0].networks : network
    if network.name == var.network_name
  ], [])
  network_openstack_ids = try([
    for network_region in one(local.selected_networks).regions : network_region.openstack_id
    if network_region.region == var.region
  ], [])

  selected_subnets = try([
    for subnet in data.ovh_cloud_project_network_private_subnets.subnets[0].subnets : subnet
    if subnet.cidr == var.subnet_cidr && contains(
      [for pool in subnet.ip_pools : pool.region],
      var.region
    )
  ], [])
}

data "ovh_cloud_projects" "projects" {}

data "ovh_cloud_project_network_privates" "networks" {
  count        = local.service_name == null ? 0 : 1
  service_name = local.service_name == null ? "" : local.service_name
}

data "ovh_cloud_project_network_private_subnets" "subnets" {
  count        = length(local.selected_networks) == 1 ? 1 : 0
  service_name = local.service_name == null ? "" : local.service_name
  network_id   = try(one(local.selected_networks).id, "")
}


output "service_name" {
  description = "OVHcloud Public Cloud service name resolved for the selected project."
  value       = local.service_name
}

output "selected_networks" {
  description = "Private network records matching network_name in the selected project."
  value       = local.selected_networks
}

output "network_openstack_ids" {
  description = "OpenStack network IDs matching the cluster region."
  value       = local.network_openstack_ids
}

output "selected_subnets" {
  description = "Subnet records matching subnet_cidr and the cluster region."
  value       = local.selected_subnets
}
