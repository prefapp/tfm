output "service_name" {
  description = "OVHcloud Public Cloud project service name."
  value       = ovh_cloud_project_database.postgresql.service_name
}

output "postgresql_id" {
  description = "ID of the managed PostgreSQL cluster."
  value       = ovh_cloud_project_database.postgresql.id
}

output "postgresql_description" {
  description = "Description assigned to the managed PostgreSQL service."
  value       = ovh_cloud_project_database.postgresql.description
}

output "postgresql_status" {
  description = "Current OVHcloud service status."
  value       = ovh_cloud_project_database.postgresql.status
}

output "postgresql_host" {
  description = "PostgreSQL direct endpoint hostname."
  value       = local.direct_endpoint.domain
}

output "postgresql_port" {
  description = "PostgreSQL direct endpoint port."
  value       = local.direct_endpoint.port
}

output "postgresql_endpoints" {
  description = "PostgreSQL service endpoint domains, ports and TLS modes; connection URIs are omitted."
  value       = local.postgresql_endpoints
}

output "postgresql_ca" {
  description = "Certificate authority certificate for verified TLS connections."
  value       = data.ovh_cloud_project_database_certificates.certificates.ca
}

output "user_secret_paths" {
  description = "OKMS paths containing direct-connection credentials by configured user key."
  value       = { for key, secret in ovh_okms_secret.user : key => secret.path }
}

output "pool_secret_paths" {
  description = "OKMS paths containing pooled connection URIs by configured pool key."
  value       = { for key, secret in ovh_okms_secret.pool : key => secret.path }
}

output "database_ids" {
  description = "OVHcloud database IDs by configured database key."
  value       = { for key, database in ovh_cloud_project_database_database.database : key => database.id }
}

output "database_names" {
  description = "Names of PostgreSQL databases managed by this module, keyed by configuration key."
  value       = { for key, database in ovh_cloud_project_database_database.database : key => database.name }
}

output "pool_endpoints" {
  description = "Non-sensitive connection pool details by pool key. URIs are deliberately omitted."
  value = {
    for key, pool in ovh_cloud_project_database_postgresql_connection_pool.pool : key => {
      name     = pool.name
      port     = pool.port
      ssl_mode = pool.ssl_mode
    }
  }
}
