module "ovh_mysql" {
  source = "../../"

  project_name   = "example-project"
  okms_id        = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  name           = "example-mysql-production"
  region         = "GRA"
  engine_version = "8.4"
  plan           = "production"
  flavor         = "b3-8"

  network_name = "example-gra-private-network"
  subnet_cidr  = "10.41.0.0/16"
  databases    = ["application", "audit"]

  backup_regions   = ["GRA", "SBG"]
  backup_time      = "02:00:00"
  maintenance_time = "04:00:00"

  advanced_configuration = {
    "mysql.sql_require_primary_key" = "true"
  }

  deletion_protection = true
}

output "mysql_status" {
  description = "Current managed MySQL service status."
  value       = module.ovh_mysql.mysql_status
}

output "mysql_endpoint" {
  description = "MySQL host and port for private TLS clients."
  value = {
    host = module.ovh_mysql.mysql_host
    port = module.ovh_mysql.mysql_port
  }
}

output "admin_secret_path" {
  description = "OKMS path storing administrator credentials."
  value       = module.ovh_mysql.admin_secret_path
}
