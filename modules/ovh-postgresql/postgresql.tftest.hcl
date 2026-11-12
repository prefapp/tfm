mock_provider "ovh" {}

run "accept_listed_options" {
  command = plan
  variables {
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
    kms_id         = "okms-123"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = local.valid_offer && local.selected_offer.disk_min == 80 && local.selected_offer.disk_max == 400 && local.selected_offer.disk_step == 10
    error_message = "The maintained catalogue should accept this offer and expose its exact storage limits."
  }
}

run "accept_published_regional_alias" {
  command = plan
  variables {
    name           = "test"
    region         = "EU-WEST-PAR"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 80
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [ovh_cloud_project_database.postgresql]
  assert {
    condition     = local.valid_offer
    error_message = "The regional alias should appear in the maintained offer catalogue."
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
    disk_size      = 80
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
    disk_size      = 80
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.plan]
}

run "reject_unlisted_engine_version" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "19"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 80
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.engine_version]
}

run "reject_unlisted_region" {
  command = plan
  variables {
    name           = "test"
    region         = "UNKNOWN"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 80
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.region]
}

run "reject_unlisted_flavor" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "B3-999"
    disk_size      = 80
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.flavor]
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
    disk_size      = 80.5
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.disk_size]
}

run "reject_non_positive_disk_size" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 0
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.disk_size]
}

run "reject_disk_below_offer_minimum" {
  command = plan
  variables {
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 70
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
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
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-4"
    disk_size      = 85
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
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
    name           = "test"
    region         = "GRA"
    network_name   = "private"
    subnet_cidr    = "10.20.0.0/16"
    engine_version = "18"
    plan           = "discovery"
    flavor         = "b3-64"
    disk_size      = 1280
    databases      = {}
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.flavor]
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
    disk_size      = 80
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
    disk_size      = 80
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
    disk_size      = 80
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
    disk_size      = 80
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
    disk_size      = 80
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
    disk_size      = 80
    databases      = { app = "same", other = "same" }
    users          = {}
    kms_id         = "okms-123"
  }
  expect_failures = [var.databases]
}
