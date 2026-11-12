module "postgresql" {
  source = "../.."

  project_id   = "<public-cloud-service-name>"
  name         = "application-db"
  region       = "GRA"
  network_name = "applications-private"
  subnet_cidr  = "10.30.0.0/16"

  engine_version = "17"
  plan           = "production"
  flavor         = "b3-8"
  disk_size      = 160

  databases = {
    app = "application"
  }

  users = {
    app = {
      name     = "application"
      database = "app"
    }
  }

  connection_pools = {
    app = {
      name     = "application-pool"
      database = "app"
      user     = "app"
      mode     = "transaction"
      size     = 20
    }
  }

  required_extensions = ["pgvector"]
  kms_id              = "<okms-id>"
}

output "pool_secret_path" {
  value = module.postgresql.pool_secret_paths["app"]
}
