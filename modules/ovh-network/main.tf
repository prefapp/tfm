data "ovh_cloud_projects" "projects" {}

resource "ovh_cloud_project_network_private" "kubernetes" {
  service_name = local.service_name
  name         = var.network_name
  vlan_id      = var.vlan_id
  regions      = [var.region]

  lifecycle {
    precondition {
      condition     = var.project_name != null || var.project_id != null
      error_message = "Debes definir project_id o project_name para seleccionar el proyecto Public Cloud."
    }

    precondition {
      condition     = local.service_name != null
      error_message = "No se encontró un único proyecto OVHcloud. Comprueba project_id o project_name; si ambos están definidos, project_id tiene prioridad."
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
