# OpenTofu-only suite: Terraform cannot mock the OVH provider's set-nested
# data source attributes (`projects`, `networks`, `subnets`), so it would never
# resolve the project, network or subnet. Terraform ignores `.tofutest.hcl`.

# A valid baseline: every run plans successfully unless it overrides one input.
variables {
  project_name   = "test-project"
  name           = "test"
  region         = "GRA"
  network_name   = "private"
  subnet_cidr    = "10.20.0.0/16"
  engine_version = "18"
  plan           = "discovery"
  flavor         = "b3-4"
  disk_size      = 80
  databases      = {}
  users          = {}
  okms_id        = "okms-123"
}

mock_provider "ovh" {
  mock_data "ovh_cloud_projects" {
    defaults = {
      projects = [{
        project_id    = "project-id"
        service_name  = "service-name"
        project_name  = "test-project"
        description   = "Test project"
        access        = "full"
        creation_date = "2024-01-01T00:00:00Z"
        expiration    = null
        manual_quota  = false
        order_id      = 1
        plan_code     = "project.2018"
        status        = "ok"
        unleash       = false
        iam           = { display_name = "test-project", id = "project-id", tags = {}, urn = "urn:v1:eu:resource:publicCloudProject:project-id" }
      }]
    }
  }

  mock_data "ovh_cloud_project_network_privates" {
    defaults = {
      networks = [{
        id      = "network-id"
        name    = "private"
        status  = "ACTIVE"
        type    = "private"
        vlan_id = 1
        regions = [
          { openstack_id = "openstack-network-gra", region = "GRA", status = "ACTIVE" },
          { openstack_id = "openstack-network-gra11", region = "GRA11", status = "ACTIVE" },
          { openstack_id = "openstack-network-par", region = "EU-WEST-PAR", status = "ACTIVE" },
        ]
      }]
    }
  }

  mock_data "ovh_cloud_project_network_private_subnets" {
    defaults = {
      subnets = [{
        id           = "subnet-id"
        cidr         = "10.20.0.0/16"
        dhcp_enabled = true
        gateway_ip   = "10.20.0.1"
        ip_pools = [
          { dhcp = true, end = "10.20.0.254", network = "10.20.0.0/16", region = "GRA", start = "10.20.0.10" },
          { dhcp = true, end = "10.20.0.254", network = "10.20.0.0/16", region = "GRA11", start = "10.20.0.10" },
          { dhcp = true, end = "10.20.0.254", network = "10.20.0.0/16", region = "EU-WEST-PAR", start = "10.20.0.10" },
        ]
      }]
    }
  }

  mock_data "ovh_cloud_project_database_certificates" {
    defaults = { ca = "test-ca" }
  }

  mock_resource "ovh_cloud_project_database" {
    defaults = {
      id     = "cluster-id"
      status = "READY"
      endpoints = [{
        component = "postgresql"
        domain    = "db.example.com"
        path      = ""
        port      = 20184
        scheme    = "postgresql"
        ssl       = true
        ssl_mode  = "required"
        uri       = "postgresql://db.example.com:20184"
      }]
    }
  }

  mock_resource "ovh_cloud_project_database_postgresql_user" {
    defaults = {
      id       = "user-id"
      password = "generated-password"
    }
  }
}

run "accept_listed_options" {
  command = plan
  assert {
    condition     = local.valid_offer && local.selected_offer.disk_min == 80 && local.selected_offer.disk_max == 400 && local.selected_offer.disk_step == 10
    error_message = "The maintained catalogue should accept this offer and expose its exact storage limits."
  }
  assert {
    condition     = ovh_cloud_project_database.postgresql.service_name == "service-name"
    error_message = "project_name should resolve to the matching project's service name."
  }
  assert {
    condition     = ovh_cloud_project_database.postgresql.nodes[0].network_id == "openstack-network-gra" && ovh_cloud_project_database.postgresql.nodes[0].subnet_id == "subnet-id"
    error_message = "The node should use the OpenStack network ID and subnet ID resolved in the database region."
  }
  assert {
    condition     = length(ovh_cloud_project_database.postgresql.backup_regions) == 0
    error_message = "An empty backup_regions input should leave the provider's default unchanged."
  }
  assert {
    condition     = output.postgresql_host == "db.example.com" && output.postgresql_port == 20184
    error_message = "The common PostgreSQL endpoint outputs should expose connection details without a credential URI."
  }
  assert {
    condition     = output.database_names == {}
    error_message = "The common database_names output should be an empty map when no databases are declared."
  }
}

run "resolve_project_by_id" {
  command = plan
  variables {
    project_id   = "project-id"
    project_name = "ignored"
  }
  assert {
    condition     = ovh_cloud_project_database.postgresql.service_name == "service-name"
    error_message = "project_id should take precedence over project_name and resolve the project."
  }
}

run "accept_users_pools_and_secrets" {
  command = plan
  variables {
    databases = { app = "app" }
    users     = { app = { name = "app", database = "app" } }
    connection_pools = {
      app = { name = "app", database = "app", user = "app", mode = "transaction", size = 5 }
    }
  }
  assert {
    condition     = ovh_okms_secret.user["app"].path == "test/app" && ovh_okms_secret.pool["app"].path == "test/pools/app"
    error_message = "Direct and pool secrets should be planned under their default paths."
  }
  assert {
    condition     = output.database_names == { app = "app" }
    error_message = "The common database_names output should map each configured key to its PostgreSQL database name."
  }
  assert {
    condition     = terraform_data.pool_user["app"].triggers_replace.user == "app" && terraform_data.pool_user["app"].triggers_replace.password_reset == null
    error_message = "The pool replacement trigger should track its configured user and password-reset generation."
  }
}

run "accept_pool_without_user_restriction" {
  command = plan
  variables {
    databases = { app = "app" }
    connection_pools = {
      app = { name = "app", database = "app", user = null, mode = "transaction", size = 5 }
    }
  }
  assert {
    condition     = terraform_data.pool_user["app"].triggers_replace.user == null && terraform_data.pool_user["app"].triggers_replace.password_reset == null
    error_message = "The pool replacement trigger should track an unrestricted user setting without a password reset."
  }
}

run "track_pool_user_password_reset" {
  command = plan
  variables {
    databases = { app = "app" }
    users = {
      app = { name = "app", database = "app", password_reset = "rotation-2" }
    }
    connection_pools = {
      app = { name = "app", database = "app", user = "app", mode = "transaction", size = 5 }
    }
  }
  assert {
    condition     = terraform_data.pool_user["app"].triggers_replace.password_reset == "rotation-2"
    error_message = "A restricted pool replacement trigger should track its user's password-reset generation."
  }
}

run "accept_published_regional_alias" {
  command = plan
  variables {
    region = "EU-WEST-PAR"
  }
  assert {
    condition     = local.valid_offer && ovh_cloud_project_database.postgresql.nodes[0].network_id == "openstack-network-par"
    error_message = "The regional alias should appear in the maintained offer catalogue."
  }
}

run "resolve_network_in_distinct_openstack_region" {
  command = plan
  variables {
    network_region = "GRA11"
  }
  assert {
    condition     = ovh_cloud_project_database.postgresql.nodes[0].region == "GRA" && ovh_cloud_project_database.postgresql.nodes[0].network_id == "openstack-network-gra11" && ovh_cloud_project_database.postgresql.nodes[0].subnet_id == "subnet-id"
    error_message = "Network lookup should use its OpenStack region while the node keeps the Managed Database region."
  }
}

run "allow_global_ip_restriction_with_opt_in" {
  command = plan
  variables {
    allow_public_access = true
    ip_restrictions     = [{ ip = "0:0:0:0:0:0:0:0/0" }]
  }
  assert {
    condition     = var.allow_public_access && local.ip_restrictions[0].ip == "0:0:0:0:0:0:0:0/0"
    error_message = "Explicit all-address opt-in should retain the equivalent zero-prefix CIDR."
  }
}

run "reject_unknown_project" {
  command = plan
  variables {
    project_name = "missing-project"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = local.service_name == null
    error_message = "An unmatched project_name must not resolve a project."
  }
}

run "reject_unknown_network" {
  command = plan
  variables {
    network_name = "missing"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_subnet_outside_network_region" {
  command = plan
  variables {
    network_region = "SBG5"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_unknown_subnet" {
  command = plan
  variables {
    subnet_cidr = "10.30.0.0/16"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_missing_user_password" {
  command = plan
  variables {
    databases = { app = "app" }
    users     = { app = { name = "app", database = "app" } }
  }
  override_resource {
    target = ovh_cloud_project_database_postgresql_user.user["app"]
    values = { id = "user-id", password = "" }
  }
  expect_failures = [ovh_okms_secret.user["app"]]
}

run "reject_invalid_cidr" {
  command = plan
  variables {
    subnet_cidr = "not-a-cidr"
  }
  expect_failures = [var.subnet_cidr]
}

run "reject_invalid_plan" {
  command = plan
  variables {
    plan = "small"
  }
  expect_failures = [var.plan]
}

run "reject_unlisted_engine_version" {
  command = plan
  variables {
    engine_version = "19"
  }
  expect_failures = [var.engine_version]
}

run "reject_unlisted_region" {
  command = plan
  variables {
    region = "UNKNOWN"
  }
  expect_failures = [var.region]
}

run "reject_unlisted_flavor" {
  command = plan
  variables {
    flavor = "B3-999"
  }
  expect_failures = [var.flavor]
}

run "reject_fractional_disk_size" {
  command = plan
  variables {
    disk_size = 80.5
  }
  expect_failures = [var.disk_size]
}

run "reject_non_positive_disk_size" {
  command = plan
  variables {
    disk_size = 0
  }
  expect_failures = [var.disk_size]
}

run "reject_disk_below_offer_minimum" {
  command = plan
  variables {
    disk_size = 70
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = !local.valid_offer
    error_message = "The catalogue must reject disk sizes below the selected offer minimum."
  }
}

run "reject_disk_off_step" {
  command = plan
  variables {
    disk_size = 85
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = !local.valid_offer
    error_message = "The catalogue must reject disk sizes that do not match the selected offer increment."
  }
}

run "reject_flavor_not_offered_for_plan" {
  command = plan
  variables {
    flavor    = "b3-64"
    disk_size = 1280
  }
  expect_failures = [var.flavor]
}

run "reject_invalid_backup_time" {
  command = plan
  variables {
    backup_time = "25:00:00"
  }
  expect_failures = [var.backup_time]
}

run "reject_duplicate_backup_regions" {
  command = plan
  variables {
    backup_regions = ["GRA", "GRA"]
  }
  expect_failures = [var.backup_regions]
}

run "reject_invalid_user_role" {
  command = plan
  variables {
    databases = { app = "app" }
    users     = { app = { name = "app", database = "app", roles = ["superuser"] } }
  }
  expect_failures = [var.users]
}

run "reject_invalid_pool_mode" {
  command = plan
  variables {
    databases = { app = "app" }
    connection_pools = {
      app = { name = "app", database = "app", mode = "invalid", size = 1 }
    }
  }
  expect_failures = [var.connection_pools]
}

run "reject_non_positive_pool_size" {
  command = plan
  variables {
    databases = { app = "app" }
    connection_pools = {
      app = { name = "app", database = "app", mode = "session", size = 0 }
    }
  }
  expect_failures = [var.connection_pools]
}

run "reject_duplicate_database_names" {
  command = plan
  variables {
    databases = { app = "same", other = "same" }
  }
  expect_failures = [var.databases]
}

run "reject_backup_regions_without_database_region" {
  command = plan
  variables {
    backup_regions = ["SBG"]
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_equivalent_ipv6_global_ip_restriction_without_opt_in" {
  command = plan
  variables {
    ip_restrictions = [{ ip = "0:0:0:0:0:0:0:0/0" }]
  }
  expect_failures = [var.ip_restrictions]
}

run "reject_global_ip_restriction_without_opt_in" {
  command = plan
  variables {
    ip_restrictions = [{ ip = "0.0.0.0/0" }]
  }
  expect_failures = [var.ip_restrictions]
}

run "reject_duplicate_user_and_pool_secret_paths" {
  command = plan
  variables {
    databases = { app = "app" }
    users     = { app = { name = "app", database = "app", secret_path = "shared" } }
    connection_pools = {
      app = { name = "app", database = "app", user = "app", mode = "session", size = 1, secret_path = "shared" }
    }
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_user_referencing_undeclared_database" {
  command = plan
  variables {
    databases = { app = "app" }
    users     = { app = { name = "app", database = "missing" } }
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_pool_referencing_undeclared_database" {
  command = plan
  variables {
    databases = { app = "app" }
    connection_pools = {
      app = { name = "app", database = "missing", mode = "session", size = 1 }
    }
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_pool_referencing_undeclared_user" {
  command = plan
  variables {
    databases = { app = "app" }
    connection_pools = {
      app = { name = "app", database = "app", user = "missing", mode = "session", size = 1 }
    }
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_unsupported_extension" {
  command = plan
  variables {
    required_extensions = ["not_an_extension"]
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_extension_unsupported_for_engine_version" {
  command = plan
  variables {
    required_extensions = ["timescaledb"]
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
}

run "reject_missing_project_selector" {
  command = plan
  variables {
    project_name = null
  }
  expect_failures = [var.project_name]
}

run "reject_disabling_deletion_protection_outside_discovery" {
  command = plan
  variables {
    plan                = "production"
    flavor              = "b3-8"
    disk_size           = 160
    deletion_protection = false
  }
  expect_failures = [check.deletion_protection]
}
