module "postgresql" {
  source = "../.."

  project_name = "example-project"
  name         = "authz"
  region       = "GRA"
  network_name = "predev-private"
  subnet_cidr  = "10.20.0.0/16"

  engine_version = "18"
  plan           = "discovery"
  flavor         = "b3-4"
  disk_size      = 80

  databases = {
    authz = "authz"
  }

  users = {
    authz = {
      name     = "authz"
      database = "authz"
    }
  }

  okms_id = "<okms-id>"
}

output "postgresql_id" {
  value = module.postgresql.postgresql_id
}

output "postgresql_endpoint" {
  value = {
    host = module.postgresql.postgresql_host
    port = module.postgresql.postgresql_port
  }
}

output "authz_secret_path" {
  value = module.postgresql.user_secret_paths["authz"]
}
