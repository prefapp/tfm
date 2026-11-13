mock_provider "ovh" {
  alias = "mock"

  mock_data "ovh_cloud_project_database_capabilities" {
    defaults = {
      engines = [{
        name            = "mysql"
        versions        = ["8.4"]
        default_version = "8.4"
        description     = "MySQL"
        ssl_modes       = ["REQUIRED"]
      }]
      plans = [
        { name = "discovery", description = "Discovery", backup_retention = "2d" },
        { name = "production", description = "Production", backup_retention = "14d" },
        { name = "advanced", description = "Advanced", backup_retention = "30d" },
      ]
      flavors = [{ name = "b3-4", core = 2, memory = 4, storage = 40 }]
      options = []
    }
  }
}

run "reject_invalid_plan" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id     = "project-id"
    okms_id        = "kms-id"
    name           = "test-mysql"
    region         = "GRA"
    engine_version = "8.4"
    plan           = "tiny"
    flavor         = "b3-4"
  }

  expect_failures = [var.plan, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_invalid_backup_time" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id          = "project-id"
    okms_id             = "kms-id"
    name                = "test-mysql"
    region              = "GRA"
    engine_version      = "8.4"
    plan                = "discovery"
    flavor              = "b3-4"
    use_private_network = false
    backup_time         = "25:00:00"
  }

  expect_failures = [var.backup_time, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_duplicate_database_names" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id          = "project-id"
    okms_id             = "kms-id"
    name                = "test-mysql"
    region              = "GRA"
    engine_version      = "8.4"
    plan                = "discovery"
    flavor              = "b3-4"
    use_private_network = false
    databases           = ["app", "app"]
  }

  expect_failures = [var.databases, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_public_cidr_without_opt_in" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id          = "project-id"
    okms_id             = "kms-id"
    name                = "test-mysql"
    region              = "GRA"
    engine_version      = "8.4"
    plan                = "discovery"
    flavor              = "b3-4"
    use_private_network = false
    ip_restrictions = [{
      ip          = "0.0.0.0/0"
      description = "Public access"
    }]
  }

  expect_failures = [var.ip_restrictions, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_invalid_cidr" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id          = "project-id"
    okms_id             = "kms-id"
    name                = "test-mysql"
    region              = "GRA"
    engine_version      = "8.4"
    plan                = "discovery"
    flavor              = "b3-4"
    use_private_network = false
    ip_restrictions = [{
      ip          = "not-a-cidr"
      description = "Invalid"
    }]
  }

  expect_failures = [var.ip_restrictions, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_invalid_backup_region_count" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id          = "project-id"
    okms_id             = "kms-id"
    name                = "test-mysql"
    region              = "GRA"
    engine_version      = "8.4"
    plan                = "discovery"
    flavor              = "b3-4"
    use_private_network = false
    backup_regions      = ["GRA", "SBG", "BHS"]
  }

  expect_failures = [var.backup_regions, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_empty_admin_secret_path" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id        = "project-id"
    okms_id           = "kms-id"
    name              = "test-mysql"
    region            = "GRA"
    engine_version    = "8.4"
    plan              = "discovery"
    flavor            = "b3-4"
    admin_secret_path = " "
  }

  expect_failures = [var.admin_secret_path, data.ovh_cloud_project_database_capabilities.capabilities]
}

run "reject_empty_network_region" {
  command = plan
  providers = {
    ovh = ovh.mock
  }

  variables {
    project_id     = "project-id"
    okms_id        = "kms-id"
    name           = "test-mysql"
    region         = "GRA"
    network_region = " "
    engine_version = "8.4"
    plan           = "discovery"
    flavor         = "b3-4"
  }

  expect_failures = [var.network_region, data.ovh_cloud_project_database_capabilities.capabilities]
}
