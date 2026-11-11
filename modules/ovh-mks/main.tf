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
      condition     = var.project_name != null || var.project_id != null
      error_message = "Set project_id or project_name to select the Public Cloud project."
    }

    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud project. Check project_id or project_name; if both are set, project_id takes precedence."
    }

    precondition {
      condition     = length(local.selected_networks) == 1
      error_message = "Could not find exactly one private network named by network_name in the selected Public Cloud project. Check that the ovh-network module has been applied."
    }

    precondition {
      condition     = length(local.network_openstack_ids) == 1
      error_message = "The private network does not have exactly one openstack_id for the cluster region. Check that the network is deployed in that region."
    }

    precondition {
      condition     = length(local.selected_subnets) == 1
      error_message = "Could not find exactly one subnet matching subnet_cidr in the selected network and region. Check the CIDR and that the ovh-network module has been applied."
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
      error_message = "The node pool name '${var.cluster_name}-${each.key}' may contain only lowercase letters, numbers, and hyphens (-), as required by OVHcloud."
    }
  }
}
