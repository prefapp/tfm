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
}

resource "ovh_cloud_project_gateway" "kubernetes" {
  service_name = local.service_name
  name         = var.gateway_name
  model        = var.gateway_model
  region       = var.region
  network_id   = one(ovh_cloud_project_network_private.kubernetes.regions_attributes[*].openstackid)
  subnet_id    = ovh_cloud_project_network_private_subnet.kubernetes.id
}
