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
  service_name = try(one(local.selected_projects).service_name, null)

  # Private ranges reserved by OVHcloud MKS; the network must not overlap them.
  mks_reserved_cidrs = [
    "10.2.0.0/16",
    "10.3.0.0/16",
    "172.17.0.0/16",
    "10.240.0.0/13",
  ]

  # HCL comparison operators only accept numbers, so IPv4 addresses are
  # converted to integers before being compared in resource preconditions.
  ipv4_addresses = distinct(concat(
    [
      var.subnet_pool_start,
      var.subnet_pool_end,
      cidrhost(var.network_cidr, 0),
      cidrhost(var.network_cidr, -1),
    ],
    [for cidr in local.mks_reserved_cidrs : cidrhost(cidr, 0)],
    [for cidr in local.mks_reserved_cidrs : cidrhost(cidr, -1)],
  ))

  ipv4_integer = {
    for address in local.ipv4_addresses : address => try(
      sum([for index, octet in split(".", address) : tonumber(octet) * pow(256, 3 - index)]),
      null
    )
  }

  subnet_pool_start_int  = local.ipv4_integer[var.subnet_pool_start]
  subnet_pool_end_int    = local.ipv4_integer[var.subnet_pool_end]
  network_first_host_int = local.ipv4_integer[cidrhost(var.network_cidr, 0)]
  network_last_host_int  = local.ipv4_integer[cidrhost(var.network_cidr, -1)]

  overlapping_reserved_cidrs = [
    for cidr in local.mks_reserved_cidrs : cidr
    if local.network_first_host_int <= local.ipv4_integer[cidrhost(cidr, -1)] &&
    local.ipv4_integer[cidrhost(cidr, 0)] <= local.network_last_host_int
  ]
}
