resource "ovh_cloud_project_database" "postgresql" {
  service_name           = local.service_name
  description            = var.name
  engine                 = "postgresql"
  version                = var.engine_version
  plan                   = var.plan
  flavor                 = var.flavor
  disk_size              = var.disk_size
  deletion_protection    = var.deletion_protection
  advanced_configuration = var.advanced_configuration
  backup_time            = var.backup_time
  backup_regions         = var.backup_regions
  maintenance_time       = var.maintenance_time

  dynamic "nodes" {
    for_each = range(local.node_count)
    content {
      region     = var.region
      network_id = try(one(local.network_openstack_ids), "")
      subnet_id  = try(one(local.selected_subnets).id, "")
    }
  }

  dynamic "ip_restrictions" {
    for_each = local.ip_restrictions
    content {
      ip          = ip_restrictions.value.ip
      description = ip_restrictions.value.description
    }
  }

  lifecycle {
    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud project. Check project_id or project_name; project_id takes precedence."
    }

    precondition {
      condition     = length(local.selected_networks) == 1 && length(local.network_openstack_ids) == 1 && length(local.selected_subnets) == 1
      error_message = "Could not resolve exactly one private network and subnet in region. Check that the ovh-network module has been applied and the name/CIDR/region match."
    }

    precondition {
      condition     = local.valid_offer
      error_message = "The selected PostgreSQL version, plan, region, flavor and disk size are not a stable private OVHcloud offer in the maintained catalogue."
    }

    precondition {
      condition     = length(var.backup_regions) == 0 || contains(var.backup_regions, var.region)
      error_message = "When backup_regions is set, it must include the database region."
    }

    precondition {
      condition     = length(distinct(concat(values(local.user_secret_paths), values(local.pool_secret_paths)))) == length(var.users) + length(var.connection_pools)
      error_message = "Every direct and pool OKMS secret path must be unique."
    }

    precondition {
      condition = alltrue([
        for user in values(var.users) : contains(keys(var.databases), user.database)
      ])
      error_message = "Every user must reference a database declared in databases."
    }

    precondition {
      condition = alltrue([
        for pool in values(var.connection_pools) :
        contains(keys(var.databases), pool.database) && (pool.user == null ? true : contains(keys(var.users), pool.user))
      ])
      error_message = "Every pool must reference a declared database and, when set, a declared user."
    }

    precondition {
      condition = alltrue([
        for extension in var.required_extensions : contains(local.supported_extensions, extension) &&
        lookup(local.extension_version_constraints, extension, true)
      ])
      error_message = "A required extension is not in the OVHcloud-supported catalogue or is not supported for the selected PostgreSQL version. Check the linked OVHcloud extension documentation."
    }
  }
}

resource "ovh_cloud_project_database_database" "database" {
  for_each = var.databases

  service_name = ovh_cloud_project_database.postgresql.service_name
  engine       = "postgresql"
  cluster_id   = ovh_cloud_project_database.postgresql.id
  name         = each.value
}

resource "ovh_cloud_project_database_postgresql_user" "user" {
  for_each = var.users

  service_name   = ovh_cloud_project_database.postgresql.service_name
  cluster_id     = ovh_cloud_project_database.postgresql.id
  name           = each.value.name
  roles          = each.value.roles
  password_reset = each.value.password_reset
}

resource "ovh_okms_secret" "user" {
  for_each = var.users

  okms_id = data.ovh_okms_resource.kms.id
  path    = local.user_secret_paths[each.key]

  metadata = {
    max_versions             = 10
    deactivate_version_after = "0s"
    custom_metadata = merge(var.secret_custom_metadata, {
      database = var.databases[each.value.database]
      username = each.value.name
      service  = var.name
      type     = "postgresql-direct"
    })
  }

  version = {
    data = jsonencode({
      host     = local.direct_endpoint.domain
      port     = local.direct_endpoint.port
      username = ovh_cloud_project_database_postgresql_user.user[each.key].name
      password = ovh_cloud_project_database_postgresql_user.user[each.key].password
      database = var.databases[each.value.database]
    })
  }
}

resource "ovh_cloud_project_database_postgresql_connection_pool" "pool" {
  for_each = var.connection_pools

  service_name = ovh_cloud_project_database.postgresql.service_name
  cluster_id   = ovh_cloud_project_database.postgresql.id
  database_id  = ovh_cloud_project_database_database.database[each.value.database].id
  name         = each.value.name
  mode         = each.value.mode
  size         = each.value.size
  user_id      = each.value.user == null ? null : ovh_cloud_project_database_postgresql_user.user[each.value.user].id
}

resource "ovh_okms_secret" "pool" {
  for_each = var.connection_pools

  okms_id = data.ovh_okms_resource.kms.id
  path    = local.pool_secret_paths[each.key]

  metadata = {
    max_versions             = 10
    deactivate_version_after = "0s"
    custom_metadata = merge(var.secret_custom_metadata, {
      database = each.value.database
      service  = var.name
      pool     = each.value.name
      type     = "postgresql-pool"
    })
  }

  version = {
    data = jsonencode({
      uri = ovh_cloud_project_database_postgresql_connection_pool.pool[each.key].uri
    })
  }
}

data "ovh_cloud_project_database_certificates" "certificates" {
  service_name = ovh_cloud_project_database.postgresql.service_name
  engine       = "postgresql"
  cluster_id   = ovh_cloud_project_database.postgresql.id
}

data "ovh_okms_resource" "kms" {
  id = var.kms_id
}

check "deletion_protection" {
  assert {
    condition     = var.deletion_protection || var.plan == "discovery"
    error_message = "Disabling deletion_protection outside the discovery plan risks deleting database data."
  }
}
