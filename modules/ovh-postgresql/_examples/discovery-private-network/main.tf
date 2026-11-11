module "postgresql" {
  source = "../.."

  project_name = "example-project"
  name         = "authz"
  region       = "GRA"
  network_name = "predev-private"
  subnet_cidr  = "10.20.0.0/16"

  postgresql_version = "18"
  plan               = "discovery"
  flavor             = "b3-4"
  disk_size          = 20

  databases = {
    authz = "authz"
  }

  users = {
    authz = {
      name     = "authz"
      database = "authz"
    }
  }

  kms_id = "<okms-id>"
}

output "cluster_id" {
  value = module.postgresql.cluster_id
}

output "authz_secret_path" {
  value = module.postgresql.user_secret_paths["authz"]
}
