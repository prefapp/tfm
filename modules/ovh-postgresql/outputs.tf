output "service_name" {
  description = "OVHcloud Public Cloud project service name."
  value       = ovh_cloud_project_database.postgresql.service_name
}

output "cluster_id" {
  description = "ID of the managed PostgreSQL cluster."
  value       = ovh_cloud_project_database.postgresql.id
}

output "endpoints" {
  description = "PostgreSQL service endpoint domains, ports and TLS modes; connection URIs are omitted."
  value = [
    for endpoint in ovh_cloud_project_database.postgresql.endpoints : {
      component = endpoint.component
      domain    = endpoint.domain
      port      = endpoint.port
      ssl       = endpoint.ssl
      ssl_mode  = endpoint.ssl_mode
    }
  ]
}

output "status" {
  description = "Current OVHcloud service status."
  value       = ovh_cloud_project_database.postgresql.status
}

output "ca_certificate" {
  description = "Certificate authority certificate for verified TLS connections."
  value       = data.ovh_cloud_project_database_certificates.certificates.ca
}

output "kms_id" {
  description = "ID of the OKMS holding database credentials."
  value       = data.ovh_okms_resource.kms.id
}

output "user_secret_paths" {
  description = "OKMS paths containing direct-connection credentials by user key."
  value       = { for key, secret in ovh_okms_secret.user : key => secret.path }
}

output "pool_secret_paths" {
  description = "OKMS paths containing pooled connection URIs by pool key."
  value       = { for key, secret in ovh_okms_secret.pool : key => secret.path }
}

output "database_ids" {
  description = "OVHcloud database IDs by configured database key."
  value       = { for key, database in ovh_cloud_project_database_database.database : key => database.id }
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
