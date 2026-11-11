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
    if subnet.cidr == var.subnet_cidr && contains([for pool in subnet.ip_pools : pool.region], var.region)
  ], [])

  database_node_counts = {
    discovery  = 1
    production = 2
    advanced   = 3
  }
  node_count = local.database_node_counts[var.plan]

  ip_restrictions = length(var.ip_restrictions) > 0 ? var.ip_restrictions : [{
    ip          = var.subnet_cidr
    description = "Private database subnet"
  }]

  direct_endpoint = one([
    for endpoint in ovh_cloud_project_database.postgresql.endpoints : endpoint
    if endpoint.component == "postgresql"
  ])

  user_secret_paths = {
    for key, user in var.users : key => coalesce(user.secret_path, "${var.name}/${user.name}")
  }
  pool_secret_paths = {
    for key, pool in var.connection_pools : key => coalesce(pool.secret_path, "${var.name}/pools/${pool.name}")
  }

  supported_extensions = toset([
    "address_standardizer", "address_standardizer_data_us", "aiven_extras",
    "bloom", "bool_plperl", "btree_gin", "btree_gist", "citext", "cube", "dblink",
    "dict_int", "earthdistance", "fuzzystrmatch", "h3", "h3_postgis", "hll", "hstore",
    "intagg", "intarray", "isn", "jsonb_plperl", "lo", "ltree", "pageinspect", "pgaudit", "pg_buffercache",
    "pg_cron", "pg_partman", "pg_prewarm", "pg_repack", "pg_similarity",
    "pg_stat_statements", "pg_trgm", "pgcrypto", "pgrowlocks", "pgstattuple",
    "pgvector", "pgvectorscale", "plperl", "plpgsql", "postgis", "postgis_legacy",
    "postgis_raster", "postgis_sfcgal", "postgis_tiger_geocoder", "postgis_topology",
    "postgres_fdw", "pgrouting", "rum", "seg", "sslinfo", "tablefunc", "tcn", "timescaledb",
    "tsm_system_rows", "tsm_system_time", "unit", "unaccent", "uuid-ossp"
  ])

  capabilities_engine = try(one([
    for engine in data.ovh_cloud_project_database_capabilities.capabilities.engines : engine
    if engine.name == "postgresql"
  ]), null)
  capabilities_plans = [
    for plan in data.ovh_cloud_project_database_capabilities.capabilities.plans : plan.name
  ]
  capabilities_flavors = [
    for flavor in data.ovh_cloud_project_database_capabilities.capabilities.flavors : flavor.name
  ]

  extension_version_constraints = {
    bool_plperl   = contains(["15", "16", "17", "18"], var.engine_version)
    hll           = contains(["15", "16", "17", "18"], var.engine_version)
    pg_similarity = contains(["15", "16", "17", "18"], var.engine_version)
    pgvector      = contains(["15", "16", "17", "18"], var.engine_version)
    pgvectorscale = contains(["16", "17"], var.engine_version)
    timescaledb   = var.engine_version != "18"
  }
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

data "ovh_cloud_project_database_capabilities" "capabilities" {
  service_name = local.service_name == null ? "" : local.service_name
}
