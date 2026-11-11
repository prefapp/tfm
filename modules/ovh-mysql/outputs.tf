output "service_name" {
  description = "OVHcloud Public Cloud service name resolved for the selected project."
  value       = local.service_name
}

output "mysql_id" {
  description = "ID of the managed MySQL service."
  value       = ovh_cloud_project_database.mysql.id
}

output "mysql_description" {
  description = "Description assigned to the managed MySQL service."
  value       = ovh_cloud_project_database.mysql.description
}

output "mysql_status" {
  description = "Current service status reported by OVHcloud."
  value       = ovh_cloud_project_database.mysql.status
}

output "mysql_host" {
  description = "MySQL endpoint hostname for TLS connections."
  value       = try(one(local.mysql_endpoints).domain, null)
}

output "mysql_port" {
  description = "MySQL endpoint port."
  value       = try(one(local.mysql_endpoints).port, null)
}

output "mysql_ca" {
  description = "Service CA certificate required for TLS connections."
  value       = data.ovh_cloud_project_database_certificates.ca.ca
}

output "database_names" {
  description = "Names of MySQL databases managed by this module."
  value       = { for name, database in ovh_cloud_project_database_database.databases : name => database.name }
}

output "node_count" {
  description = "Number of nodes created for the selected MySQL plan."
  value       = length(local.node_ranges)
}

output "private_network_id" {
  description = "Regional OpenStack ID of the attached private network, or null when private networking is disabled."
  value       = var.use_private_network ? try(one(local.network_openstack_ids), null) : null
}

output "subnet_id" {
  description = "ID of the attached private subnet, or null when private networking is disabled."
  value       = var.use_private_network ? try(one(local.selected_subnets).id, null) : null
}
