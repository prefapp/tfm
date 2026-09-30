resource "ovh_cloud_project_kube" "production" {
  service_name       = local.service_name
  name               = var.cluster_name
  region             = var.region
  plan               = var.cluster_plan
  version            = var.cluster_version
  update_policy      = var.update_policy
  private_network_id = try(one(local.network_openstack_ids), "")
  nodes_subnet_id    = try(one(local.selected_subnets).id, "")

  lifecycle {
    precondition {
      condition     = local.service_name != null
      error_message = "No se encontró un único proyecto OVHcloud. Comprueba project_id o project_name; si ambos están definidos, project_id tiene prioridad."
    }

    precondition {
      condition     = length(local.selected_networks) == 1
      error_message = "No se encontró exactamente una red privada con network_name en el proyecto Public Cloud seleccionado. Comprueba que el módulo 02-network ya se haya aplicado."
    }

    precondition {
      condition     = length(local.network_openstack_ids) == 1
      error_message = "La red privada no tiene un único openstack_id para la región del clúster. Comprueba que la red esté desplegada en esa región."
    }

    precondition {
      condition     = length(local.selected_subnets) == 1
      error_message = "No se encontró exactamente una subred con subnet_cidr en la red y región seleccionadas. Comprueba el CIDR y que el módulo 02-network ya se haya aplicado."
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "production" {
  for_each = var.node_pools

  service_name       = local.service_name
  kube_id            = ovh_cloud_project_kube.production.id
  name               = "${var.cluster_name}-${each.key}"
  flavor_name        = var.node_flavor
  desired_nodes      = each.value.desired_nodes
  min_nodes          = each.value.min_nodes
  max_nodes          = each.value.max_nodes
  autoscale          = var.autoscale
  anti_affinity      = var.anti_affinity
  availability_zones = length(each.value.availability_zones) > 0 ? each.value.availability_zones : null

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z0-9-]+$", "${var.cluster_name}-${each.key}"))
      error_message = "El nombre del node pool '${var.cluster_name}-${each.key}' solo puede contener letras minúsculas, números y guiones (-), según los requisitos de OVHcloud."
    }
  }
}
