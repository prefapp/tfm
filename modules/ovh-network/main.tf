data "ovh_cloud_projects" "projects" {}

resource "ovh_cloud_project_network_private" "kubernetes" {
  service_name = local.service_name
  name         = var.network_name
  vlan_id      = var.vlan_id
  regions      = [var.region]

  lifecycle {
    precondition {
      condition     = var.project_name != null || var.project_id != null
      error_message = "Set project_id or project_name to select the Public Cloud project."
    }

    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud project. Check project_id or project_name; if both are set, project_id takes precedence."
    }

    precondition {
      condition     = length(local.overlapping_reserved_cidrs) == 0
      error_message = "network_cidr must not overlap the OVHcloud MKS reserved ranges 10.2.0.0/16, 10.3.0.0/16, 172.17.0.0/16, and 10.240.0.0/13."
    }
  }
}

resource "ovh_cloud_project_network_private_subnet" "kubernetes" {
  service_name = local.service_name
  network_id   = ovh_cloud_project_network_private.kubernetes.id
  region       = var.region
  network      = var.network_cidr
  start        = var.subnet_pool_start
  end          = var.subnet_pool_end
  dhcp         = true
  no_gateway   = false

  lifecycle {
    precondition {
      condition = try(
        local.network_first_host_int <= local.subnet_pool_start_int &&
        local.subnet_pool_start_int <= local.network_last_host_int &&
        local.network_first_host_int <= local.subnet_pool_end_int &&
        local.subnet_pool_end_int <= local.network_last_host_int,
        false
      )
      error_message = "subnet_pool_start and subnet_pool_end must both be valid IP addresses inside network_cidr."
    }

    precondition {
      condition     = try(local.subnet_pool_start_int <= local.subnet_pool_end_int, false)
      error_message = "subnet_pool_start must be less than or equal to subnet_pool_end."
    }
  }
}

resource "ovh_cloud_project_gateway" "kubernetes" {
  service_name = local.service_name
  name         = var.gateway_name
  model        = var.gateway_model
  region       = var.region
  network_id   = one(ovh_cloud_project_network_private.kubernetes.regions_attributes[*].openstackid)
  subnet_id    = ovh_cloud_project_network_private_subnet.kubernetes.id
}
