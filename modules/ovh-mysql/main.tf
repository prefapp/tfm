resource "ovh_cloud_project_database" "mysql" {
  service_name           = local.service_name
  description            = var.name
  engine                 = "mysql"
  version                = var.engine_version
  plan                   = var.plan
  flavor                 = var.flavor
  disk_size              = var.disk_size
  advanced_configuration = var.advanced_configuration
  backup_time            = var.backup_time
  maintenance_time       = var.maintenance_time
  backup_regions         = var.backup_regions
  deletion_protection    = var.deletion_protection

  dynamic "nodes" {
    for_each = local.node_ranges
    content {
      region     = var.region
      network_id = var.use_private_network ? try(one(local.network_openstack_ids), null) : null
      subnet_id  = var.use_private_network ? try(one(local.selected_subnets).id, null) : null
    }
  }

  dynamic "ip_restrictions" {
    for_each = local.effective_ip_restrictions
    content {
      ip          = ip_restrictions.value.ip
      description = ip_restrictions.value.description
    }
  }

  lifecycle {
    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud Public Cloud project."
    }

    precondition {
      condition     = length(local.mysql_engines) == 1
      error_message = "MySQL is not present in the selected project's current database capabilities."
    }

    precondition {
      condition = try(
        length(local.mysql_engines) == 1 && contains(one(local.mysql_engines).versions, var.engine_version),
        false
      )
      error_message = "The requested MySQL version is not available in the selected project's current database capabilities."
    }

    precondition {
      condition     = contains([for plan in local.mysql_plans : plan.name], var.plan)
      error_message = "The requested MySQL plan is not present in the selected project's current database capabilities."
    }

    precondition {
      condition     = length(local.mysql_flavors) == 1
      error_message = "The requested flavor is not present in the selected project's current database capabilities."
    }

    precondition {
      condition     = !var.use_private_network || (var.network_name != null && var.subnet_cidr != null)
      error_message = "Set network_name and subnet_cidr when use_private_network is true."
    }

    precondition {
      condition     = !var.use_private_network || length(local.selected_networks) == 1
      error_message = "Could not find exactly one private network matching network_name in the selected project."
    }

    precondition {
      condition     = !var.use_private_network || length(local.network_openstack_ids) == 1
      error_message = "The selected private network has no unique regional OpenStack ID for region."
    }

    precondition {
      condition     = !var.use_private_network || length(local.selected_subnets) == 1
      error_message = "Could not find exactly one subnet matching subnet_cidr in the selected network and region."
    }

    precondition {
      condition     = var.backup_regions == null || contains(var.backup_regions, var.region)
      error_message = "backup_regions must include the MySQL node region."
    }
  }
}

resource "ovh_cloud_project_database_database" "databases" {
  for_each = toset(var.databases)

  service_name = local.service_name
  engine       = "mysql"
  cluster_id   = ovh_cloud_project_database.mysql.id
  name         = each.value
}

check "deletion_protection_recommendation" {
  assert {
    condition     = var.deletion_protection || var.plan == "discovery"
    error_message = "OVHcloud deletion protection is disabled for a non-discovery MySQL plan."
  }
}
