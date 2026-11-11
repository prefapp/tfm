module "ovh_mysql" {
  source = "../../"

  project_name   = "example-project"
  name           = "example-mysql-discovery"
  region         = "GRA"
  engine_version = "8.4"
  plan           = "discovery"
  flavor         = "b3-4"

  # Create the private network and subnet first, for example with ovh-network.
  network_name = "example-gra-private-network"
  subnet_cidr  = "10.41.0.0/16"
  databases    = ["application"]

  deletion_protection = true
}

output "mysql_host" {
  description = "Private MySQL endpoint hostname."
  value       = module.ovh_mysql.mysql_host
}

output "mysql_ca" {
  description = "CA certificate to verify the MySQL TLS connection."
  value       = module.ovh_mysql.mysql_ca
}

output "database_names" {
  description = "Logical databases created in the service."
  value       = module.ovh_mysql.database_names
}
