mock_provider "ovh" {}

mock_provider "external" {
  mock_data "external" {
    defaults = {
      result = { compatible = "false" }
    }
  }
}

run "external_result_is_available_during_plan" {
  command = plan
  variables {
    project_id     = "project-id"
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = data.external.database_offer.result.compatible == "false"
    error_message = "The external data source must return the mocked boolean result."
  }
}

run "reject_invalid_cidr" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "not-a-cidr"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.subnet_cidr]
}

run "reject_invalid_plan" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "small"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.plan]
}

run "reject_fractional_disk_size" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20.5
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.disk_size]
}

run "reject_invalid_backup_time" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    backup_time    = "25:00:00"
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.backup_time]
}

run "reject_duplicate_backup_regions" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    backup_regions = ["GRA", "GRA"]
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.backup_regions]
}

run "reject_invalid_user_role" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = { app = "app" }
    users          = { app = { name = "app", database = "app", roles = ["superuser"] } }
    kms_id         = "okms-123"
  }
  expect_failures = [var.users]
}

run "reject_invalid_pool_mode" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = { app = "app" }
    users          = {}
    connection_pools = {
      app = { name = "app", database = "app", mode = "invalid", size = 1 }
    }
    kms_id = "okms-123"
  }
  expect_failures = [var.connection_pools]
}

run "reject_non_positive_pool_size" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = { app = "app" }
    users          = {}
    connection_pools = {
      app = { name = "app", database = "app", mode = "session", size = 0 }
    }
    kms_id = "okms-123"
  }
  expect_failures = [var.connection_pools]
}

run "reject_duplicate_database_names" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 20
    databases      = { app = "same", other = "same" }
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.databases]
}
