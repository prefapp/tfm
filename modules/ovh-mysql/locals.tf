locals {
  selected_projects = [
    for project in data.ovh_cloud_projects.projects.projects : project
    if var.project_id != null ? (
      project.project_id == var.project_id || project.service_name == var.project_id
      ) : (
      var.project_name != null ? (
        lower(project.project_name) == lower(var.project_name) || lower(project.description) == lower(var.project_name)
      ) : false
    )
  ]
  service_name      = try(one(local.selected_projects).service_name, null)
  admin_secret_path = var.admin_secret_path != null ? var.admin_secret_path : "mysql/${var.name}/avnadmin"
  network_region    = var.network_region != null ? var.network_region : var.region

  selected_networks = try([
    for network in data.ovh_cloud_project_network_privates.networks[0].networks : network
    if network.name == var.network_name
  ], [])
  network_openstack_ids = try([
    for network_region in one(local.selected_networks).regions : network_region.openstack_id
    if network_region.region == local.network_region
  ], [])

  selected_subnets = try([
    for subnet in data.ovh_cloud_project_network_private_subnets.subnets[0].subnets : subnet
    if subnet.cidr == var.subnet_cidr && contains(
      [for pool in subnet.ip_pools : pool.region],
      local.network_region
    )
  ], [])

  node_count = {
    discovery  = 1
    production = 2
    advanced   = 3
  }
  node_ranges = range(lookup(local.node_count, var.plan, 0))

  default_ip_restrictions = var.use_private_network && var.subnet_cidr != null ? [
    { ip = var.subnet_cidr, description = "Private subnet" }
  ] : []
  effective_ip_restrictions = var.ip_restrictions == null ? local.default_ip_restrictions : var.ip_restrictions

  mysql_engines = [
    for engine in data.ovh_cloud_project_database_capabilities.capabilities.engines : engine
    if engine.name == "mysql"
  ]
  mysql_plans = [
    for plan in data.ovh_cloud_project_database_capabilities.capabilities.plans : plan
    if contains(["discovery", "production", "advanced"], plan.name)
  ]
  mysql_flavors = [
    for flavor in data.ovh_cloud_project_database_capabilities.capabilities.flavors : flavor
    if flavor.name == var.flavor
  ]

  mysql_endpoints = [
    for endpoint in ovh_cloud_project_database.mysql.endpoints : endpoint
    if endpoint.component == "mysql"
  ]
}

data "ovh_cloud_projects" "projects" {}

data "ovh_cloud_project_network_privates" "networks" {
  count        = var.use_private_network && local.service_name != null ? 1 : 0
  service_name = local.service_name == null ? "" : local.service_name
}

data "ovh_cloud_project_network_private_subnets" "subnets" {
  count        = var.use_private_network && length(local.selected_networks) == 1 ? 1 : 0
  service_name = local.service_name == null ? "" : local.service_name
  network_id   = try(one(local.selected_networks).id, "")
}

data "ovh_cloud_project_database_capabilities" "capabilities" {
  service_name = local.service_name == null ? "" : local.service_name

  lifecycle {
    precondition {
      condition     = var.project_name != null || var.project_id != null
      error_message = "Set project_id or project_name to select the Public Cloud project."
    }

    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud project. Check project_id or project_name; if both are set, project_id takes precedence."
    }
  }
}
