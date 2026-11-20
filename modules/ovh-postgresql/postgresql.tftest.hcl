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

mock_provider "ovh" {}

run "reject_invalid_cidr" {
  command = plan
  variables {
    subnet_cidr = "not-a-cidr"
  }
  expect_failures = [var.subnet_cidr]
}

run "reject_missing_project_selector" {
  command = plan
  variables {
    project_name = null
  }
  expect_failures = [var.project_name]
}

run "reject_invalid_plan" {
  command = plan
  variables {
    plan = "small"
  }
  expect_failures = [var.plan]
}

run "reject_unlisted_region" {
  command = plan
  variables {
    region = "UNKNOWN"
  }
  expect_failures = [var.region]
}

run "reject_unlisted_engine_version" {
  command = plan
  variables {
    engine_version = "19"
  }
  expect_failures = [var.engine_version]
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

run "reject_global_ip_restriction_without_opt_in" {
  command = plan
  variables {
    ip_restrictions = [{ ip = "0.0.0.0/0" }]
  }
  expect_failures = [var.ip_restrictions]
}

run "reject_duplicate_extensions" {
  command = plan
  variables {
    required_extensions = ["pgvector", "pgvector"]
  }
  expect_failures = [var.required_extensions]
}
